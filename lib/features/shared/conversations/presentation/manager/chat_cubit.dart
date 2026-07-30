import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/utils/media_compressor.dart';
import 'package:fitness_day/core/services/socket_service.dart';
import 'package:fitness_day/features/shared/conversations/data/datasources/chat_remote_datasource.dart';
import 'package:fitness_day/features/shared/conversations/data/models/message_model.dart';
import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';
import 'package:fitness_day/features/shared/conversations/domain/usecases/get_messages_usecase.dart';
import 'package:fitness_day/features/shared/conversations/domain/usecases/get_specialist_messages_usecase.dart';
import 'package:fitness_day/features/shared/conversations/domain/usecases/open_chat_usecase.dart';
import 'package:fitness_day/features/shared/conversations/domain/usecases/open_specialist_chat_usecase.dart';
import 'package:fitness_day/features/shared/conversations/domain/usecases/send_media_usecase.dart';
import 'package:fitness_day/features/shared/conversations/domain/usecases/send_specialist_media_usecase.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/chat_state.dart';

/// Orchestrates the chat feature for both User and Specialist roles.
///
/// When [isSpecialistMode] is true, specialist endpoints are used:
///   POST /specialist/chat/:userId/open
///   GET  /specialist/chat/:id/messages
///   POST /specialist/chat/:id/media
class ChatCubit extends Cubit<ChatState> {
  final OpenChatUseCase _openChatUseCase;
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMediaUseCase _sendMediaUseCase;
  final OpenSpecialistChatUseCase _openSpecialistChatUseCase;
  final GetSpecialistMessagesUseCase _getSpecialistMessagesUseCase;
  final SendSpecialistMediaUseCase _sendSpecialistMediaUseCase;
  final SocketService _socketService;
  final SecureCache _secureCache;

  /// When true, specialist endpoints are used instead of user endpoints.
  bool _isSpecialistMode = false;

  ChatCubit({
    required OpenChatUseCase openChatUseCase,
    required GetMessagesUseCase getMessagesUseCase,
    required SendMediaUseCase sendMediaUseCase,
    required OpenSpecialistChatUseCase openSpecialistChatUseCase,
    required GetSpecialistMessagesUseCase getSpecialistMessagesUseCase,
    required SendSpecialistMediaUseCase sendSpecialistMediaUseCase,
    required SocketService socketService,
    required SecureCache secureCache,
  })  : _openChatUseCase = openChatUseCase,
        _getMessagesUseCase = getMessagesUseCase,
        _sendMediaUseCase = sendMediaUseCase,
        _openSpecialistChatUseCase = openSpecialistChatUseCase,
        _getSpecialistMessagesUseCase = getSpecialistMessagesUseCase,
        _sendSpecialistMediaUseCase = sendSpecialistMediaUseCase,
        _socketService = socketService,
        _secureCache = secureCache,
        super(const ChatInitial());

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Entry point: call this from [ChatDetailsPage.initState].
  ///
  /// Set [isSpecialistMode] = true when the caller is the Specialist app side.
  /// In that case, [specialistId] is actually the *userId* (the client's ID).
  Future<void> openChat({
    String? existingConversationId,
    String? specialistId,
    bool isSpecialistMode = false,
  }) async {
    _isSpecialistMode = isSpecialistMode;
    debugPrint('[ChatCubit] openChat — conversationId=$existingConversationId  specialistId=$specialistId  isSpecialistMode=$isSpecialistMode');
    emit(const ChatLoading());

    String? conversationId = existingConversationId;

    if (conversationId == null || conversationId.isEmpty) {
      if (specialistId == null || specialistId.isEmpty) {
        debugPrint('[ChatCubit] ❌ No specialistId or conversationId provided');
        emit(const ChatError('لا يوجد أخصائي محدد أو محادثة سابقة.'));
        return;
      }

      // For specialist mode: open via /specialist/chat/:userId/open
      // For user mode: open via /chat/open
      final ApiResult<String> openResult = isSpecialistMode
          ? await _openSpecialistChatUseCase(specialistId)
          : await _openChatUseCase(specialistId);

      if (openResult is FailureResult) {
        debugPrint('[ChatCubit] ❌ openChat failed: ${(openResult as FailureResult).failure.message}');
        emit(ChatError((openResult as FailureResult).failure.message));
        return;
      }
      conversationId = (openResult as Success<String>).data;
      debugPrint('[ChatCubit] ✅ openChat success — conversationId=$conversationId');
    }

    // Fetch messages using the correct endpoint for the role.
    final ApiResult<ChatMessagesPage> messagesResult = isSpecialistMode
        ? await _getSpecialistMessagesUseCase(conversationId)
        : await _getMessagesUseCase(conversationId);

    if (messagesResult is FailureResult) {
      debugPrint('[ChatCubit] ❌ getMessages failed: ${(messagesResult as FailureResult).failure.message}');
      emit(ChatError((messagesResult as FailureResult).failure.message));
      return;
    }
    final page = (messagesResult as Success<ChatMessagesPage>).data;
    final ordered = page.messages.reversed.toList();
    debugPrint('[ChatCubit] ✅ getMessages — ${ordered.length} messages loaded');

    emit(ChatLoaded(
      conversationId: conversationId,
      messages: ordered,
      otherParty: page.otherParty,
      currentPage: 1,
      totalPages: page.totalPages,
    ));

    // Connect socket.
    await _connectSocket();

    // Register listeners BEFORE emitRead so we never miss a fast chat:read response.
    _socketService.onMessageReceived(_onIncomingMessage);
    _socketService.onUserTyping(_onUserTyping);
    _socketService.onChatRead(_onChatRead);
    _socketService.onChatDelivered(_onChatDelivered);

    // Inform the server we've read everything.
    _socketService.emitRead(conversationId: conversationId);
  }

  /// Sends [isTyping] status to the server.
  void sendTyping(bool isTyping) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;
    debugPrint('[ChatCubit] sendTyping=$isTyping');
    _socketService.emitTyping(
      conversationId: currentState.conversationId,
      isTyping: isTyping,
    );
  }

  /// Sends a plain-text message via Socket.IO + shows an optimistic bubble.
  void sendMessage(String text) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    sendTyping(false);

    debugPrint('[ChatCubit] 📤 sendMessage: "$text"');
    _socketService.sendMessage(
      conversationId: currentState.conversationId,
      text: text,
    );

    final optimistic = MessageModel(
      id: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: currentState.conversationId,
      text: text,
      senderType: 'user',
      isMine: true,
      status: MessageStatus.sent, // single check mark immediately on send
      createdAt: DateTime.now(),
    );

    emit(currentState.copyWithNewMessage(optimistic));
  }

  /// Uploads [files] to `POST /chat/:id/media` and appends the returned
  /// message (with its media list) to the chat.
  ///
  /// Images are re-encoded by [MediaCompressor] first so a full-size camera
  /// photo doesn't go up as several MB (and doesn't trip the server's upload
  /// size limit). The optimistic bubble shows the picked files straight from
  /// disk, with a single check mark, so the message looks sent right away.
  Future<void> sendMedia(List<XFile> files) async {
    final currentState = state;
    if (currentState is! ChatLoaded || files.isEmpty) return;

    debugPrint('[ChatCubit] 📤 sendMedia — ${files.length} file(s)');

    // Optimistic message: local previews + "sent" tick, replaced by the
    // server message once the upload finishes.
    final optimistic = MessageModel(
      id: 'optimistic_media_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: currentState.conversationId,
      text: '',
      senderType: 'user',
      isMine: true,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
      // The name is passed explicitly rather than derived from the path: for a
      // document it is what the server stores as the title, so the sender's
      // own bubble shows exactly what the recipient will see.
      media: files
          .map((f) => ChatMediaAttachment.local(f.path, title: f.name))
          .toList(),
    );
    emit(currentState.copyWithNewMessage(optimistic));

    final compressed = await MediaCompressor.compressAll(files);

    // Use specialist endpoint if in specialist mode.
    final result = _isSpecialistMode
        ? await _sendSpecialistMediaUseCase(
            conversationId: currentState.conversationId,
            files: compressed,
          )
        : await _sendMediaUseCase(
            conversationId: currentState.conversationId,
            files: compressed,
          );

    if (result is FailureResult) {
      debugPrint('[ChatCubit] ❌ sendMedia failed: ${(result as FailureResult).failure.message}');
      // Remove optimistic placeholder on failure.
      final latest = state;
      if (latest is ChatLoaded) {
        final without = latest.messages
            .where((m) => m.id != optimistic.id)
            .toList();
        emit(latest.copyWith(messages: without));
      }
      return;
    }

    final uploadedMsg = (result as Success<ChatMessage>).data;
    debugPrint('[ChatCubit] ✅ sendMedia success — msgId=${uploadedMsg.id}  media=${uploadedMsg.media.length}');

    // The upload response doesn't always carry a `status`; the message *is*
    // on the server at this point, so never fall back to the clock icon.
    final delivered = uploadedMsg.status == MessageStatus.unknown
        ? uploadedMsg.copyWith(status: MessageStatus.sent)
        : uploadedMsg;

    // Replace optimistic with real message.
    final latest = state;
    if (latest is ChatLoaded) {
      final updated = latest.messages.map((m) {
        if (m.id == optimistic.id) return delivered;
        return m;
      }).toList();
      emit(latest.copyWith(messages: updated));
    }
  }

  /// Fetches the next (older) page of messages and prepends them.
  /// Called when the user scrolls to the top of the message list.
  Future<void> loadMoreMessages() async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    final nextPage = currentState.currentPage + 1;
    debugPrint('[ChatCubit] 📜 loadMoreMessages — page=$nextPage');

    emit(currentState.copyWithLoadingMore());

    final ApiResult<ChatMessagesPage> result = _isSpecialistMode
        ? await _getSpecialistMessagesUseCase(
            currentState.conversationId,
            page: nextPage,
          )
        : await _getMessagesUseCase(
            currentState.conversationId,
            page: nextPage,
          );

    if (result is FailureResult) {
      debugPrint('[ChatCubit] ❌ loadMoreMessages failed: ${(result as FailureResult).failure.message}');
      // Revert loading state silently — don't replace screen with error.
      final latest = state;
      if (latest is ChatLoaded) {
        emit(latest.copyWith(isLoadingMore: false));
      }
      return;
    }

    final page = (result as Success<ChatMessagesPage>).data;
    // Newer pages from the API are DESC (newest first), reverse to get oldest→newest order.
    final olderMessages = page.messages.reversed.toList();
    debugPrint('[ChatCubit] ✅ loadMoreMessages — got ${olderMessages.length} older messages');

    final latest = state;
    if (latest is ChatLoaded) {
      emit(latest.copyWithOlderMessages(
        olderMessages: olderMessages,
        newPage: nextPage,
        newTotalPages: page.totalPages,
      ));
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _connectSocket() async {
    final token = await _secureCache.getToken();
    if (token != null && token.isNotEmpty) {
      debugPrint('[ChatCubit] 🔌 Connecting socket...');
      _socketService.connect(token);
    } else {
      debugPrint('[ChatCubit] ⚠️  No token found — socket not connected');
    }
  }

  /// Handles `chat:message` events from the server.
  ///
  /// Cases:
  ///   a) isMine == true  → server echo of our own message → replace optimistic with server incoming.
  ///   b) isMine == false → message from other party → append + emit read.
  void _onIncomingMessage(Map<String, dynamic> data) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final incoming = MessageModel.fromJson(data);
    debugPrint('[ChatCubit] 📩 _onIncomingMessage — id=${incoming.id}  isMine=${incoming.isMine}  status=${incoming.status}  media=${incoming.media.length}');

    if (incoming.isMine) {
      // Server echo → replace matching optimistic bubble with server message.
      bool replaced = false;
      final updated = currentState.messages.map((m) {
        // Only match an optimistic bubble of the same kind — otherwise a
        // text echo could swallow a media bubble that is still uploading.
        if (!replaced &&
            (m.id == incoming.id ||
                (m.id.startsWith('optimistic_') &&
                    m.isMine &&
                    m.isMedia == incoming.isMedia))) {
          replaced = true;
          final finalStatus = (m.status == MessageStatus.delivered &&
                  incoming.status != MessageStatus.seen)
              ? MessageStatus.delivered
              : incoming.status;
          debugPrint('[ChatCubit] ♻️  Replaced msg with server msg (id=${incoming.id}, status=$finalStatus)');
          return incoming.copyWith(status: finalStatus);
        }
        return m;
      }).toList();

      if (!replaced && !currentState.messages.any((m) => m.id == incoming.id)) {
        updated.add(incoming);
      }

      // Use copyWith so currentPage/totalPages/isLoadingMore (pagination
      // state) survive this update instead of silently resetting to their
      // defaults — that reset was what made the list jump/scroll on its
      // own while an older page was still being fetched.
      emit(currentState.copyWith(messages: updated));
      return;
    }

    // Other party's message — mark as read immediately.
    debugPrint('[ChatCubit] ➕ New message from other party — emitting read');
    _socketService.emitRead(conversationId: currentState.conversationId);
    emit(currentState.copyWithNewMessage(incoming));
  }

  void _onUserTyping(bool isTyping) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;
    debugPrint('[ChatCubit] ⌨️  Other party typing=$isTyping');
    emit(currentState.copyWithTyping(isTyping));
  }

  /// Called when the server emits `chat:read` — the other party read our messages.
  void _onChatRead() {
    final currentState = state;
    if (currentState is! ChatLoaded) return;
    debugPrint('[ChatCubit] 🔵 _onChatRead → all outgoing messages → seen');
    emit(currentState.copyWithAllMessagesSeen());
  }

  /// Called when the server emits `chat:delivered` with a messageId.
  /// Updates the corresponding outgoing message status to delivered.
  void _onChatDelivered(String messageId) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;
    debugPrint('[ChatCubit] 📦 _onChatDelivered for id=$messageId');
    final newState = currentState.copyWithMessageDelivered(messageId);
    debugPrint('[ChatCubit] 📦 Emitting new state with updated messages count=${newState.messages.length}');
    emit(newState);
  }

  @override
  Future<void> close() {
    debugPrint('[ChatCubit] 🛑 close — removing socket listeners');
    _socketService.offMessageReceived();
    return super.close();
  }
}