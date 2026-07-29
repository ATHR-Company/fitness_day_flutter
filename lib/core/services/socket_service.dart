import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';

/// Manages the Socket.IO connection for the real-time chat feature.
///
/// Registered as a **LazySingleton** in GetIt — one persistent connection
/// shared across the app.
class SocketService {
  final SecureCache _secureCache;

  SocketService({required SecureCache secureCache})
      : _secureCache = secureCache;

  io.Socket? _socket;
  String? _currentToken;

  // ── Server-kick backoff ───────────────────────────────────────────────────
  //
  // socket.io deliberately does **not** auto-reconnect after an
  // `io server disconnect`: the server made a decision, and retrying instantly
  // just asks it to make the same decision again. Reconnecting anyway is still
  // right for us — the kick is usually a transient server-side session problem
  // — but it has to back off and give up, otherwise a server that kicks every
  // connection turns into an unbounded connect/kick loop that drains the
  // battery and floods the server.
  Timer? _reconnectTimer;
  int _kickCount = 0;
  DateTime? _connectedAt;

  static const int _kMaxKickRetries = 5;
  static const Duration _kBaseKickDelay = Duration(seconds: 2);
  static const Duration _kMaxKickDelay = Duration(seconds: 60);

  /// A connection that survived this long counts as healthy, so a later kick
  /// starts the backoff over instead of inheriting an old streak.
  static const Duration _kStableAfter = Duration(seconds: 10);

  bool get isConnected => _socket?.connected ?? false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void connect(String token) {
    _currentToken = token;
    // An explicit connect is a fresh start — anything the backoff was holding
    // back is now moot.
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _kickCount = 0;

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
      _connectedAt = DateTime.now();
      debugPrint('[Socket] ✅ Connected — id=${_socket?.id}');
    });

    _socket!.onDisconnect((reason) {
      debugPrint('[Socket] ❌ Disconnected — reason=$reason');
      if (reason == 'io server disconnect') _scheduleReconnectAfterKick();
    });

    _socket!.onConnectError((err) {
      debugPrint('[Socket] ⚠️  Connect error: $err');
    });

    _socket!.onError((err) {
      debugPrint('[Socket] ⚠️  Error: $err');
    });

    _socket!.connect();
  }

  /// Opens the connection using the stored access token, doing nothing when no
  /// session exists.
  ///
  /// Every sign-in path calls this straight after persisting its tokens.
  /// Without it, the socket was only ever opened at app launch, so a user who
  /// signed in during the same run had no live chat until the next cold start.
  Future<void> connectWithStoredToken() async {
    try {
      final String? token = await _secureCache.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[Socket] ⚠️  No stored token — not connecting');
        return;
      }
      connect(token);
    } catch (e) {
      debugPrint('[Socket] ⚠️  Could not read token to connect: $e');
    }
  }

  void disconnect() {
    debugPrint('[Socket] 🔌 Disconnecting...');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _kickCount = 0;
    _connectedAt = null;
    _currentToken = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ── Server-kick handling ──────────────────────────────────────────────────

  /// Queues one backoff-delayed reconnect after the server hung up on us.
  void _scheduleReconnectAfterKick() {
    if (_currentToken == null) return;
    // Only one retry may be in flight; without this a kick arriving while a
    // retry is already pending would stack timers and defeat the backoff.
    if (_reconnectTimer?.isActive ?? false) return;

    final DateTime? connectedAt = _connectedAt;
    if (connectedAt != null &&
        DateTime.now().difference(connectedAt) >= _kStableAfter) {
      _kickCount = 0;
    }
    _connectedAt = null;

    if (_kickCount >= _kMaxKickRetries) {
      debugPrint(
        '[Socket] ⛔ Server kept closing the connection immediately '
        '($_kMaxKickRetries attempts) — giving up. This is a server-side '
        'refusal, not a network failure; the next send or chat screen will '
        'try again.',
      );
      return;
    }

    _kickCount++;
    final Duration delay = _kickDelay(_kickCount);
    debugPrint(
      '[Socket] 🔄 Reconnecting after io server disconnect '
      '(attempt $_kickCount/$_kMaxKickRetries in ${delay.inSeconds}s)...',
    );
    _reconnectTimer = Timer(delay, _reconnectWithFreshToken);
  }

  Duration _kickDelay(int attempt) {
    final int seconds = _kBaseKickDelay.inSeconds * (1 << (attempt - 1));
    return seconds >= _kMaxKickDelay.inSeconds
        ? _kMaxKickDelay
        : Duration(seconds: seconds);
  }

  /// Re-reads the access token before retrying. The old code reconnected with
  /// whatever token the socket was opened with, so once `TokenInterceptor`
  /// rotated it the socket kept presenting a token the server no longer
  /// accepts — and every retry was refused for the same reason.
  Future<void> _reconnectWithFreshToken() async {
    if (_socket == null || _currentToken == null) return;
    try {
      final String? token = await _secureCache.getToken();
      if (token != null && token.isNotEmpty) {
        _currentToken = token;
        _socket!.auth = {'token': token};
      }
    } catch (e) {
      debugPrint('[Socket] ⚠️  Could not read token for reconnect: $e');
    }
    if (_socket == null) return;
    _socket!.connect();
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
