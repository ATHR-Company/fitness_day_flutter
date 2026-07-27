import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:fitness_day/core/constant/api_endpoints.dart';

/// Manages the Socket.IO connection for the real-time chat feature.
///
/// Registered as a **LazySingleton** in GetIt — one persistent connection
/// shared across the app.
class SocketService {
  io.Socket? _socket;
  String? _currentToken;

  bool get isConnected => _socket?.connected ?? false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void connect(String token) {
    _currentToken = token;

    if (_socket != null) {
      if (_socket!.connected) {
        debugPrint('[Socket] ⚡ Already connected — skipping');
        return;
      } else {
        debugPrint('[Socket] 🔄 Reconnecting existing socket...');
        _socket!.auth = {'token': token};
        _socket!.connect();
        return;
      }
    }

    debugPrint('[Socket] 🔌 Connecting to ${ApiEndpoints.socketUrl}...');

    _socket = io.io(
      ApiEndpoints.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[Socket] ✅ Connected — id=${_socket?.id}');
    });

    _socket!.onDisconnect((reason) {
      debugPrint('[Socket] ❌ Disconnected — reason=$reason');
      // If server forcibly disconnected, attempt auto-reconnect using saved token.
      if (reason == 'io server disconnect' && _currentToken != null) {
        debugPrint('[Socket] 🔄 Reconnecting after io server disconnect...');
        _socket?.connect();
      }
    });

    _socket!.onConnectError((err) {
      debugPrint('[Socket] ⚠️  Connect error: $err');
    });

    _socket!.onError((err) {
      debugPrint('[Socket] ⚠️  Error: $err');
    });

    _socket!.connect();
  }

  void disconnect() {
    debugPrint('[Socket] 🔌 Disconnecting...');
    _currentToken = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ── Sending ───────────────────────────────────────────────────────────────

  void sendMessage({
    required String conversationId,
    required String text,
  }) {
    _ensureConnected();
    if (_socket == null || !_socket!.connected) {
      debugPrint('[Socket] ⚠️  sendMessage — socket not connected after reconnect attempt');
      return;
    }
    debugPrint('[Socket] 📤 chat:send  conversationId=$conversationId  text=$text');
    _socket!.emit('chat:send', {
      'conversationId': conversationId,
      'text': text,
    });
  }

  void emitTyping({
    required String conversationId,
    required bool isTyping,
  }) {
    _ensureConnected();
    if (_socket == null || !_socket!.connected) return;
    debugPrint('[Socket] ⌨️  chat:typing  isTyping=$isTyping');
    _socket!.emit('chat:typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  void emitRead({required String conversationId}) {
    _ensureConnected();
    if (_socket == null || !_socket!.connected) {
      debugPrint('[Socket] ⚠️  emitRead — socket not connected, skipping');
      return;
    }
    debugPrint('[Socket] 👁  chat:read  conversationId=$conversationId');
    _socket!.emit('chat:read', {'conversationId': conversationId});
  }

  // ── Listening ─────────────────────────────────────────────────────────────

  void onMessageReceived(void Function(Map<String, dynamic> data) callback) {
    debugPrint('[Socket] 👂 Registered listener: chat:message');
    _socket?.on('chat:message', (raw) {
      if (raw is Map) {
        final data = Map<String, dynamic>.from(raw);
        debugPrint('[Socket] 📩 chat:message received — id=${data['id']}  isMine=${data['isMine']}  status=${data['status']}');
        callback(data);
      }
    });
  }

  void onUserTyping(void Function(bool isTyping) callback) {
    debugPrint('[Socket] 👂 Registered listener: chat:typing');
    _socket?.on('chat:typing', (raw) {
      if (raw is Map) {
        final isTyping = raw['isTyping'] as bool? ?? false;
        debugPrint('[Socket] ⌨️  chat:typing received — isTyping=$isTyping');
        callback(isTyping);
      }
    });
  }

  void onChatRead(void Function() callback) {
    debugPrint('[Socket] 👂 Registered listener: chat:read');
    _socket?.on('chat:read', (_) {
      debugPrint('[Socket] 🔵 chat:read received → marking all sent messages as seen');
      callback();
    });
  }

  // New: Listener for chat:delivered events, providing the delivered message ID.
  void onChatDelivered(void Function(String messageId) callback) {
    debugPrint('[Socket] 👂 Registered listener: chat:delivered');
    _socket?.on('chat:delivered', (raw) {
      if (raw is Map && raw['messageId'] is String) {
        final id = raw['messageId'] as String;
        debugPrint('[Socket] 📦 chat:delivered received for id=$id');
        callback(id);
      }
    });
  }

  /// Removes all chat-specific event listeners.
  /// Must be called in [ChatCubit.close] to prevent duplicate events.
  void offMessageReceived() {
    debugPrint('[Socket] 🛑 Removing chat listeners (message, typing, read)');
    _socket?.off('chat:message');
    _socket?.off('chat:typing');
    _socket?.off('chat:read');
    _socket?.off('chat:delivered');
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  void _ensureConnected() {
    if ((_socket == null || !_socket!.connected) && _currentToken != null) {
      debugPrint('[Socket] 🔌 Socket disconnected — attempting automatic reconnect');
      connect(_currentToken!);
    }
  }
}
