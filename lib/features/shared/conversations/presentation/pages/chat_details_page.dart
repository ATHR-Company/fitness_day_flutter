import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/utils/lost_media_recovery.dart';
import 'package:fitness_day/core/utils/media_permissions.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/media_source_sheet.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/chat_state.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/chat_voice_recorder.dart';
import 'package:fitness_day/features/shared/conversations/presentation/models/local_chat_message.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_attachment_sheet.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_header.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_input_bar.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_messages_list.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_reaction_picker.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/local_chat_messages_list.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/conversations_shimmer_loading.dart';
import 'package:fitness_day/features/specialist/clients/presentation/pages/client_profile_page.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';

/// One conversation.
///
/// Two modes live behind the same screen:
///   - **Server-backed** (`isSpecialist: true`) — history comes from the API
///     and messages travel over Socket.IO through [ChatCubit].
///   - **In-memory** — the AI and user-to-user screens, which keep their
///     bubbles in a local [LocalChatMessage] list.
class ChatDetailsPage extends StatefulWidget {
  final String? title;
  final bool isAi;
  final bool isSpecialist;

  /// The specialist's user-ID, used to open/fetch the conversation via
  /// `POST /chat/open`. When [isSpecialistMode] is true this is the *client's*
  /// userId and is sent to `POST /specialist/chat/:userId/open`.
  final String? specialistId;

  /// Optional existing conversationId returned by `GET /chat`.
  final String? conversationId;

  /// Avatar of the other party, passed from the conversations list so the
  /// header shows the same picture instantly. When omitted, the avatar that
  /// comes back with the messages response is used instead.
  final String? avatarUrl;

  /// When true, the page uses specialist-side endpoints:
  ///   GET  /specialist/chat/:id/messages
  ///   POST /specialist/chat/:userId/open
  ///   POST /specialist/chat/:id/media
  final bool isSpecialistMode;

  const ChatDetailsPage({
    super.key,
    this.title,
    this.isAi = false,
    this.isSpecialist = false,
    this.specialistId,
    this.conversationId,
    this.avatarUrl,
    this.isSpecialistMode = false,
  });

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage>
    with WidgetsBindingObserver {
  /// How long the composer stays quiet before we tell the other side that the
  /// user stopped typing.
  static const Duration _typingIdleDelay = Duration(milliseconds: 1500);

  /// Distance from the far end of the reversed list that triggers the next page.
  static const double _loadMoreThreshold = 300;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final ChatVoiceRecorder _recorder = ChatVoiceRecorder();

  /// Cubit is created via GetIt and lives for the lifetime of this page.
  late final ChatCubit _chatCubit;

  /// Bubbles of the in-memory chats — unused in server-backed mode.
  final List<LocalChatMessage> _localMessages = [];

  Timer? _typingTimer;
  bool _isTypingSignalOn = false;

  /// The last pagination page we saw — any state change that increments this
  /// means an older page just arrived; we must NOT scroll in that case.
  /// Initialized to 1; updated to the real value on first ChatLoaded emission.
  int _lastSeenPage = 1;

  bool get _isServerBacked =>
      widget.isSpecialist &&
      (widget.conversationId != null || widget.specialistId != null);

  @override
  void initState() {
    super.initState();
    _chatCubit = GetIt.instance<ChatCubit>();
    _messageController.addListener(_onComposerChanged);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);

    if (_isServerBacked) {
      // openChat sends `chat:enter` itself once the conversation id is known —
      // it can only be resolved after the API call when the screen was opened
      // with a specialistId instead of a conversationId.
      _chatCubit.openChat(
        existingConversationId: widget.conversationId,
        specialistId: widget.specialistId,
        isSpecialistMode: widget.isSpecialistMode,
      );
    } else {
      _seedLocalMessages();
    }

    // Only server-backed chats can actually send; claiming a stranded file in a
    // local chat would consume it with nowhere to put it.
    if (_isServerBacked) _recoverLostAttachment();
  }

  /// Notifications hinge on this. The server holds back a push only while it
  /// believes this conversation is on screen, and on Android the socket often
  /// stays alive well after the user leaves the app — so backgrounding without
  /// a `chat:leave` means the user silently stops getting notified while the
  /// phone is in their pocket.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isServerBacked) return;
    if (state == AppLifecycleState.resumed) {
      _chatCubit.enterChat();
    } else {
      // paused / inactive / detached / hidden — the user is not looking.
      _chatCubit.leaveChat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _recorder.dispose();
    // close() sends `chat:leave`, so popping the screen resumes pushes.
    _chatCubit.close();
    super.dispose();
  }

  /// Seed two dummy bubbles so the in-memory screens aren't empty on open.
  void _seedLocalMessages() {
    final DateTime now = DateTime.now();
    _localMessages.addAll([
      LocalChatMessage(
        kind: LocalMessageKind.text,
        isMe: false,
        time: now,
        text: widget.isAi
            ? 'conversations.dummy_welcome'.tr()
            : 'conversations.dummy_message_1'.tr(),
      ),
      LocalChatMessage(
        kind: LocalMessageKind.text,
        isMe: true,
        time: now,
        text: widget.isAi
            ? 'conversations.dummy_reply'.tr()
            : 'conversations.dummy_message_2'.tr(),
      ),
    ]);
  }

  // ── Scrolling ──────────────────────────────────────────────────────────────

  /// The list is reversed, so "older messages" live at the *end* of the scroll
  /// extent. Loading a previous page therefore appends below the viewport and
  /// never shifts what the user is looking at.
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (!position.hasContentDimensions || position.maxScrollExtent <= 0) return;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) return;

    final state = _chatCubit.state;
    if (state is ChatLoaded && state.hasMore && !state.isLoadingMore) {
      _chatCubit.loadMoreMessages();
    }
  }

  /// The list is reversed, so the newest message sits at offset 0.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// Jumps to the newest message when it arrives while the user is already at
  /// the bottom — an older page loading in must never steal the scroll.
  /// Scroll to the newest message only when:
  ///   1. An optimistic message was just appended (we sent a message), OR
  ///   2. The other party sent a message AND we were already at the bottom.
  ///
  /// A pagination load arriving ([currentPage] increased) is explicitly
  /// excluded — we never scroll when the user is reading history.
  void _onChatStateChanged(BuildContext context, ChatState state) {
    // Before the early returns below: the conversation may well load empty, and
    // a recovered attachment still has to go out.
    _flushRecoveredMedia();

    if (state is! ChatLoaded || state.messages.isEmpty) return;

    // Sync _lastSeenPage on the very first ChatLoaded emission (which now
    // carries pages 1+2 merged, so currentPage may already be 2).
    if (_lastSeenPage == 1 && state.currentPage > 1) {
      _lastSeenPage = state.currentPage;
      // This is the initial load — scroll to bottom to show newest messages.
      _scrollToBottom();
      return;
    }

    // A new older page just arrived — record it and stay put.
    if (state.currentPage > _lastSeenPage) {
      _lastSeenPage = state.currentPage;
      return;
    }
    _lastSeenPage = state.currentPage;

    // Still loading more — don't act yet.
    if (state.isLoadingMore) return;

    final last = state.messages.last;
    final bool isOptimistic = last.id.startsWith('optimistic_');
    final bool isAtBottom =
        _scrollController.hasClients &&
        _scrollController.position.pixels < _loadMoreThreshold;

    if (isOptimistic || (!last.isMine && isAtBottom)) _scrollToBottom();
  }

  // ── Sending ────────────────────────────────────────────────────────────────

  void _onComposerChanged() {
    if (!widget.isSpecialist) return;

    if (!_isTypingSignalOn && _messageController.text.trim().isNotEmpty) {
      _isTypingSignalOn = true;
      _chatCubit.sendTyping(true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(_typingIdleDelay, () {
      if (!_isTypingSignalOn) return;
      _isTypingSignalOn = false;
      _chatCubit.sendTyping(false);
    });
  }

  void _sendText() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    if (_isServerBacked) {
      _chatCubit.sendMessage(text);
      _scrollToBottom();
      return;
    }

    setState(() {
      _localMessages.add(
        LocalChatMessage(
          kind: LocalMessageKind.text,
          isMe: true,
          time: DateTime.now(),
          text: text,
        ),
      );
    });
    _scrollToBottom();
  }

  void _sendMedia(List<XFile> files) {
    if (files.isEmpty) return;
    _chatCubit.sendMedia(files);
    _scrollToBottom();
  }

  /// Attachment recovered from a camera capture that outlived this screen.
  ///
  /// Held rather than sent straight away: [ChatCubit.sendMedia] drops anything
  /// handed to it before the conversation is loaded, and on the way back from a
  /// process kill the load has not even started yet.
  List<XFile> _pendingRecoveredMedia = const <XFile>[];

  /// Claims a photo or video the camera captured while Android was killing this
  /// app, then sends it as soon as the conversation is up. See
  /// [LostMediaRecovery].
  Future<void> _recoverLostAttachment() async {
    final List<XFile> lost = await LostMediaRecovery.take();
    if (lost.isEmpty || !mounted) return;

    _pendingRecoveredMedia = lost;
    _flushRecoveredMedia();
  }

  /// Sends the recovered attachment once — retried from the state listener until
  /// the chat is loaded, so nothing is lost to a slow first fetch.
  void _flushRecoveredMedia() {
    if (_pendingRecoveredMedia.isEmpty) return;
    if (_chatCubit.state is! ChatLoaded) return;

    final List<XFile> files = _pendingRecoveredMedia;
    _pendingRecoveredMedia = const <XFile>[];
    _sendMedia(files);
  }

  // ── Attachments ────────────────────────────────────────────────────────────

  /// Asks for the permission the chosen [source] needs, explaining the refusal
  /// (and offering the settings screen) when it isn't granted.
  Future<bool> _ensureMediaAccess(ImageSource source) {
    return MediaPermissions.ensure(
      context,
      source == ImageSource.camera
          ? MediaPermissionKind.camera
          : MediaPermissionKind.gallery,
    );
  }

  Future<void> _openAttachmentSheet() async {
    final ChatAttachmentType? choice = await showChatAttachmentSheet(context);
    if (choice == null || !mounted) return;

    switch (choice) {
      case ChatAttachmentType.camera:
        await _pickImage(ImageSource.camera);
      case ChatAttachmentType.gallery:
        await _pickImage(ImageSource.gallery);
      case ChatAttachmentType.video:
        await _pickVideo();
      case ChatAttachmentType.document:
        await _pickDocument();
    }
  }

  /// Gallery picks are multi-select; the camera returns a single shot. Both are
  /// compressed so the upload can't trip a 413 Request Entity Too Large.
  Future<void> _pickImage(ImageSource source) async {
    if (!await _ensureMediaAccess(source)) return;
    if (!mounted) return;

    try {
      final List<XFile> files;
      if (source == ImageSource.gallery) {
        files = await _imagePicker.pickMultiImage(
          imageQuality: 70,
          maxWidth: 1920,
          maxHeight: 1920,
        );
      } else {
        final XFile? shot = await _imagePicker.pickImage(
          source: source,
          imageQuality: 70,
          maxWidth: 1920,
          maxHeight: 1920,
        );
        files = shot == null ? const [] : [shot];
      }
      if (mounted) {
        _sendMedia(files);
      }
    } catch (e) {
      // Handle picker errors gracefully - most are user cancellations
      debugPrint('ChatDetailsPage._pickImage error: $e');
    }
  }

  /// Asks camera-or-gallery first, then picks a single video.
  Future<void> _pickVideo() async {
    final ImageSource? source = await showMediaSourceSheet(context);
    if (source == null || !mounted) return;
    if (!await _ensureMediaAccess(source)) return;
    if (!mounted) return;

    try {
      final XFile? file = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 3),
      );
      if (file != null && mounted) {
        _sendMedia([file]);
      }
    } catch (e) {
      debugPrint('ChatDetailsPage._pickVideo error: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      // PDF only — the server accepts no other document type, so offering Word
      // or Excel here just produced an upload that always failed.
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      final picked = result?.files.single;
      if (picked?.path != null && mounted) {
        _sendMedia([XFile(picked!.path!, name: picked.name)]);
      }
    } catch (e) {
      debugPrint('ChatDetailsPage._pickDocument error: $e');
    }
  }

  // ── Voice notes ────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    final bool granted = await MediaPermissions.ensure(
      context,
      MediaPermissionKind.microphone,
    );
    if (!granted || !mounted) return;

    final bool started = await _recorder.start();
    if (started || !mounted) return;

    showAppSnackBar(
      context,
      text: 'conversations.mic_permission_denied'.tr(),
      isError: true,
    );
  }

  Future<void> _sendRecording() async {
    final file = await _recorder.stop();
    if (file != null) _sendMedia([XFile(file.path)]);
  }

  // ── Reactions (in-memory chats only) ───────────────────────────────────────

  void _react(LocalChatMessage message) {
    showChatReactionPicker(
      context,
      current: message.reaction,
      onSelected: (emoji) => setState(() => message.reaction = emoji),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  /// The client whose profile the header links to.
  ///
  /// [ChatDetailsPage.specialistId] is the id the caller opened the chat with —
  /// in specialist mode that *is* the client's userId, and it is the same one
  /// the clients list navigates with. The party returned with the messages is
  /// the fallback for a chat opened straight from a conversationId.
  String? get _clientId {
    if (!widget.isSpecialistMode) return null;
    final String? fromCaller = widget.specialistId;
    if (fromCaller != null && fromCaller.isNotEmpty) return fromCaller;
    final state = _chatCubit.state;
    final String? fromChat =
        state is ChatLoaded ? state.otherParty?.id : null;
    return (fromChat != null && fromChat.isNotEmpty) ? fromChat : null;
  }

  /// Opens the client's profile from the header. A no-op outside specialist
  /// mode — a client tapping their specialist's name has nowhere to land.
  void _openClientProfile() {
    final String? clientId = _clientId;
    if (clientId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClientProfilePage(userId: clientId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatCubit,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: LoaderHud(
          isCall: false,
          child: TopCenteredConstrainedBox(
            horizontalPadding: 0,
            child: Column(
              children: [
                ChatHeader(
                  title: widget.title,
                  avatarUrl: widget.avatarUrl,
                  isAi: widget.isAi,
                  isSpecialist: widget.isSpecialist,
                  onProfileTap: _openClientProfile,
                ),
                Expanded(
                  child: BlocConsumer<ChatCubit, ChatState>(
                    listener: _onChatStateChanged,
                    builder: (context, state) => switch (state) {
                      ChatLoading() => const ChatMessagesShimmer(),
                      ChatError(:final message, :final error) => AppErrorView(
                        error: error,
                        message: message,
                      ),
                      ChatLoaded() => ChatMessagesList(
                        state: state,
                        controller: _scrollController,
                      ),
                      ChatInitial() => LocalChatMessagesList(
                        messages: _localMessages,
                        controller: _scrollController,
                        onReact: _react,
                      ),
                    },
                  ),
                ),
                ListenableBuilder(
                  listenable: _recorder,
                  builder: (context, _) => ChatInputBar(
                    controller: _messageController,
                    isRecording: _recorder.isRecording,
                    recordedFor: _recorder.elapsed,
                    onSend: _sendText,
                    onAttach: _openAttachmentSheet,
                    onStartRecording: _startRecording,
                    onCancelRecording: _recorder.cancel,
                    onSendRecording: _sendRecording,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
