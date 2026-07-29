import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/utils/attachment_opener.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/media_source_sheet.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/chat_cubit.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/chat_state.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/conversations_shimmer_loading.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';

/// Kinds of message a bubble can render. Everything here is local/in-memory —
/// no backend wiring yet; picked media and recordings are shown straight from
/// their on-device file path.
enum _MsgKind { text, image, video, audio, file }

class _ChatMessage {
  final _MsgKind kind;
  final String? text; // text messages
  final String? path; // file path for image/video/audio/file
  final String? fileName; // display name for a document
  final bool isMe;
  final DateTime time;

  /// Local emoji reaction attached by long-pressing the bubble. Mutable and
  /// in-memory only — no backend, so it isn't persisted.
  String? reaction;

  _ChatMessage({
    required this.kind,
    required this.isMe,
    required this.time,
    this.text,
    this.path,
    this.fileName,
  });
}

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

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();

  /// Cubit is created via GetIt and lives for the lifetime of this page.
  late final ChatCubit _chatCubit;

  /// Local message list used only for AI / non-specialist chats (no backend).
  final List<_ChatMessage> _messages = [];

  bool _hasText = false;

  // Recording state
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  String? _recordPath;
  // Typing status timer
  Timer? _typingTimer;
  bool _isCurrentlyTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      final has = _messageController.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);

      // Typing event logic
      if (widget.isSpecialist) {
        if (!_isCurrentlyTyping && has) {
          _isCurrentlyTyping = true;
          _chatCubit.sendTyping(true);
        }
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(milliseconds: 1500), () {
          if (_isCurrentlyTyping) {
            _isCurrentlyTyping = false;
            _chatCubit.sendTyping(false);
          }
        });
      }
    });

    // Create the Cubit and kick off the chat loading sequence.
    _chatCubit = GetIt.instance<ChatCubit>();

    // Pagination: load more when scrolled near the top.
    _scrollController.addListener(_onScroll);

    // Only fetch from backend when talking to a specialist.
    // AI chat keeps using local/mock messages.
    if (widget.isSpecialist &&
        (widget.conversationId != null || widget.specialistId != null)) {
      _chatCubit.openChat(
        existingConversationId: widget.conversationId,
        specialistId: widget.specialistId,
        isSpecialistMode: widget.isSpecialistMode,
      );
    } else {
      // Seed mock messages for AI and user-to-user chats.
      _seedLocalMessages();
    }
  }

  /// The list is [ListView.builder.reverse]d, so "older messages" live at the
  /// *end* of the scroll extent. Loading a previous page therefore appends
  /// below the viewport and never shifts what the user is looking at — no
  /// offset-restore maths, no jumping.
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final pos = _scrollController.position;
    if (!pos.hasContentDimensions) return;
    if (pos.maxScrollExtent <= 0) return;

    if (pos.pixels >= pos.maxScrollExtent - 300) {
      final st = _chatCubit.state;
      if (st is ChatLoaded && st.hasMore && !st.isLoadingMore) {
        _chatCubit.loadMoreMessages();
      }
    }
  }

  /// Seed two dummy bubbles so non-specialist screens aren't empty on open.
  void _seedLocalMessages() {
    final DateTime now = DateTime.now();
    _messages.addAll([
      _ChatMessage(
        kind: _MsgKind.text,
        isMe: false,
        time: now,
        text: widget.isAi
            ? 'conversations.dummy_welcome'.tr()
            : 'conversations.dummy_message_1'.tr(),
      ),
      _ChatMessage(
        kind: _MsgKind.text,
        isMe: true,
        time: now,
        text: widget.isAi
            ? 'conversations.dummy_reply'.tr()
            : 'conversations.dummy_message_2'.tr(),
      ),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recordTimer?.cancel();
    _recorder.dispose();
    _chatCubit.close();
    super.dispose();
  }

  // ── Message helpers ────────────────────────────────────────────────────────

  void _addMessage(_ChatMessage msg) {
    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  /// The list is reversed, so the newest message sits at offset 0.
  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (jump) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendText() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    if (widget.isSpecialist && widget.specialistId != null) {
      // Real send — goes through Socket.IO via ChatCubit.
      _chatCubit.sendMessage(text);
      // Scroll happens reactively when BlocBuilder rebuilds.
      _scrollToBottom();
    } else {
      // AI / non-specialist: keep local behaviour.
      _addMessage(_ChatMessage(
        kind: _MsgKind.text,
        isMe: true,
        time: DateTime.now(),
        text: text,
      ));
    }
  }

  // ── Attachments ────────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        // Allow selecting multiple images (compressed to prevent 413 Request Entity Too Large).
        final List<XFile> files = await _imagePicker.pickMultiImage(
          imageQuality: 70,
          maxWidth: 1920,
          maxHeight: 1920,
        );
        if (files.isNotEmpty) {
          _chatCubit.sendMedia(files);
          _scrollToBottom();
        }
      } else {
        // Camera — single image.
        final XFile? file = await _imagePicker.pickImage(
          source: source,
          imageQuality: 70,
          maxWidth: 1920,
          maxHeight: 1920,
        );
        if (file != null) {
          _chatCubit.sendMedia([file]);
          _scrollToBottom();
        }
      }
    } catch (_) {}
  }

  /// Asks camera-or-gallery first, then picks a single video.
  Future<void> _pickVideo() async {
    final ImageSource? source = await showMediaSourceSheet(context);
    if (source == null || !mounted) return;
    try {
      final XFile? file = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 3),
      );
      if (file != null) {
        _chatCubit.sendMedia([file]);
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'zip'],
      );
      final picked = result?.files.single;
      if (picked?.path != null) {
        _chatCubit.sendMedia([XFile(picked!.path!, name: picked.name)]);
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _openAttachmentPanel() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        Widget option({
          required IconData icon,
          required Color color,
          required String label,
          required VoidCallback onTap,
        }) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(sheetContext);
              onTap();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 26.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  label,
                  style: TextStyleManager.style10Medium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'conversations.attachment_title'.tr(),
                  style: TextStyleManager.style14Bold
                      .copyWith(color: AppColors.black),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    option(
                      icon: Icons.camera_alt_rounded,
                      color: AppColors.primary,
                      label: 'conversations.attach_camera'.tr(),
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    option(
                      icon: Icons.photo_rounded,
                      color: Colors.purple,
                      label: 'conversations.attach_gallery'.tr(),
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    option(
                      icon: Icons.videocam_rounded,
                      color: Colors.redAccent,
                      label: 'conversations.attach_video'.tr(),
                      onTap: _pickVideo,
                    ),
                    option(
                      icon: Icons.insert_drive_file_rounded,
                      color: Colors.blueAccent,
                      label: 'conversations.attach_document'.tr(),
                      onTap: _pickDocument,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Voice recording ────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        if (mounted) {
          showAppSnackBar(context, text: 'conversations.mic_permission_denied'.tr(), isError: true);
        }
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      _recordPath = path;
      _recordSeconds = 0;
      setState(() => _isRecording = true);
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordSeconds++);
      });
    } catch (_) {
      _resetRecording();
    }
  }

  Future<void> _stopAndSendRecording() async {
    _recordTimer?.cancel();
    try {
      final path = await _recorder.stop();
      final finalPath = path ?? _recordPath;
      if (finalPath != null && File(finalPath).existsSync()) {
        _chatCubit.sendMedia([XFile(finalPath)]);
        _scrollToBottom();
      }
    } catch (_) {}
    _resetRecording();
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    try {
      final path = await _recorder.stop();
      final p = path ?? _recordPath;
      if (p != null) {
        final f = File(p);
        if (f.existsSync()) await f.delete();
      }
    } catch (_) {}
    _resetRecording();
  }

  void _resetRecording() {
    _recordTimer?.cancel();
    _recordTimer = null;
    _recordPath = null;
    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _fmtTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm =
        t.hour >= 12 ? 'shared_mock_pm'.tr() : 'shared_mock_am'.tr();
    return '$h:$m $ampm';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
                _buildHeader(context),
                Expanded(
                  child: BlocConsumer<ChatCubit, ChatState>(
                      listener: (context, state) {
                        // The list is reversed, so nothing has to be restored
                        // after an older page loads — it is appended off-screen
                        // below the viewport. The only scroll we still drive is
                        // "jump to the newest message" when a message arrives
                        // while the user is already at the bottom.
                        if (state is! ChatLoaded ||
                            state.isLoadingMore ||
                            state.messages.isEmpty) {
                          return;
                        }

                        final last = state.messages.last;
                        final isOptimistic = last.id.startsWith('optimistic_');
                        final isAtBottom = _scrollController.hasClients &&
                            _scrollController.position.pixels < 300;

                        if (isOptimistic || (!last.isMine && isAtBottom)) {
                          _scrollToBottom();
                        }
                      },
                      builder: (context, state) {
                        // ── Loading ───────────────────────────────────────────
                        if (state is ChatLoading) {
                          return const ChatMessagesShimmer();
                        }

                        // ── Error ─────────────────────────────────────────────
                        if (state is ChatError) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.w),
                              child: Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: TextStyleManager.style11Medium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }

                        // ── Loaded (real messages from server) ────────────────
                        if (state is ChatLoaded) {
                          final msgs = state.messages;
                          // reverse: true → index 0 is the NEWEST message and
                          // sits at the bottom of the screen. Older pages are
                          // appended at the far end, so loading them can never
                          // shift what the user is currently looking at.
                          final int tailCount = state.isLoadingMore ? 1 : (state.hasMore ? 0 : 1);
                          // Typing bubble sits at index 0 — visually the last
                          // bubble, right under the newest message.
                          final int headCount = state.isOtherPartyTyping ? 1 : 0;
                          return ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 20.h),
                            itemCount: msgs.length + headCount + tailCount,
                            itemBuilder: (context, rawIndex) {
                              if (headCount == 1 && rawIndex == 0) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 16.h),
                                  child: _buildTypingBubble(),
                                );
                              }
                              final int index = rawIndex - headCount;

                              if (index < msgs.length) {
                                final msg = msgs[msgs.length - 1 - index];
                                return Padding(
                                  padding: EdgeInsets.only(top: 16.h),
                                  child: _buildServerBubble(msg),
                                );
                              }

                              // Last item (visually the top of the list):
                              // spinner while an older page loads, otherwise
                              // the "Today" label once everything is loaded.
                              if (state.isLoadingMore) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 16.h),
                                  child: Center(
                                    child: SizedBox(
                                      width: 22.w,
                                      height: 22.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: EdgeInsets.only(top: 16.h),
                                child: Center(
                                  child: Text(
                                    'conversations.today'.tr(),
                                    style: TextStyleManager.style11Medium,
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        // ── Initial / non-specialist (local mock) ─────────────
                        return ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 20.h),
                          itemCount: _messages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 24.h),
                                child: Center(
                                  child: Text(
                                    'conversations.today'.tr(),
                                    style: TextStyleManager.style11Medium,
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: _buildBubble(_messages[index - 1]),
                            );
                          },
                        );
                      },
                    ),
                ),
                _buildInputArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "… is typing" bubble, shown while the other party is typing.
  /// Same look as the AI coach chat so both screens behave alike.
  Widget _buildTypingBubble() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Icons.more_horiz, color: AppColors.primary, size: 20.sp),
      ),
    );
  }

  // ── Server message bubble (WhatsApp Style) ──────────────────────────────────

  /// Builds a bubble from a real [ChatMessage] entity.
  /// Supports:
  ///   - Single image / video
  ///   - Multiple images → 2-column grid
  ///   - Plain text
  ///   - Optimistic placeholder (status == unknown, no media yet)
  Widget _buildServerBubble(ChatMessage msg) {
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final bool hasText = msg.text.isNotEmpty;
    final bool hasMedia = msg.isMedia;

    final EdgeInsets bubblePadding = hasMedia
        ? EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 4.h)
        : EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 6.h);

    return Align(
      alignment: msg.isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.76.sw),
        margin: EdgeInsets.symmetric(vertical: 2.h),
        padding: bubblePadding,
        decoration: BoxDecoration(
          color: msg.isMine
              ? AppColors.white
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft: Radius.circular(msg.isMine ? 14.r : 2.r),
            bottomRight: Radius.circular(msg.isMine ? 2.r : 14.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Optimistic media placeholder ─────────────────────────────
            if (!hasMedia && msg.status == MessageStatus.unknown && !hasText)
              Container(
                width: 200.w,
                height: 140.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),

            // ── Media grid ───────────────────────────────────────────────
            if (hasMedia) _buildMediaGrid(msg),

            // ── Text caption / plain text ────────────────────────────────
            if (hasText)
              Padding(
                padding: hasMedia
                    ? EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 2.h)
                    : EdgeInsets.zero,
                child: Text(
                  msg.text,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: TextStyleManager.style11Medium.copyWith(
                    fontSize: 13.sp,
                    height: 1.35,
                  ),
                ),
              ),

            if (!hasMedia) SizedBox(height: 3.h),

            // ── Metadata row (Time + checkmarks) ─────────────────────────
            // Sits on the bubble background (never on top of the media), so
            // it always uses the readable dark colors — the old white-on-white
            // variant made the tick invisible on media messages.
            Padding(
              padding: hasMedia
                  ? EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 2.h)
                  : EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _fmtTime(msg.createdAt),
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 9.sp,
                    ),
                  ),
                  if (msg.isMine) ...[
                    SizedBox(width: 4.w),
                    _buildWhatsAppStatusIcon(msg.status),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a grid of media items.
  ///
  /// - 1 item → full-width image/video
  /// - 2 items → side by side
  /// - 3+ items → 2-column grid with a "+N more" overlay on the last cell
  Widget _buildMediaGrid(ChatMessage msg) {
    final items = msg.media;
    if (items.isEmpty) return const SizedBox.shrink();

    if (items.length == 1) {
      return _buildSingleMedia(items.first, isMine: msg.isMine);
    }

    // Show max 4 items in grid, rest hidden with counter.
    const int maxVisible = 4;
    final visibleItems = items.take(maxVisible).toList();
    final hiddenCount = items.length - maxVisible;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visibleItems.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 2.w,
          crossAxisSpacing: 2.w,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, i) {
          final attachment = visibleItems[i];
          final isLast = i == visibleItems.length - 1 && hiddenCount > 0;

          Widget cell = _buildMediaCell(attachment);

          if (isLast) {
            cell = Stack(
              fit: StackFit.expand,
              children: [
                cell,
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Text(
                      '+$hiddenCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return GestureDetector(
            onTap: () => _openMedia(attachment),
            child: cell,
          );
        },
      ),
    );
  }

  /// Single image or video — full width.
  Widget _buildSingleMedia(ChatMediaAttachment attachment, {bool isMine = true}) {
    if (attachment.isImage) {
      return _buildImageBubble(attachment);
    } else if (attachment.isVideo) {
      return _buildVideoBubble(attachment);
    } else if (attachment.isAudio) {
      return _AudioBubble(
        path: attachment.url,
        isMe: isMine,
        isNetwork: !attachment.isLocal,
      );
    }
    // PDF / Document / File — tap opens it (native app, else in-app WebView).
    final fileName = Uri.tryParse(attachment.url)?.pathSegments.last ??
        attachment.url.split('/').last;
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    return GestureDetector(
      onTap: () => _openMedia(attachment),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPdf
                  ? Icons.picture_as_pdf_rounded
                  : Icons.insert_drive_file_rounded,
              color: isPdf ? Colors.redAccent : AppColors.primary,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyleManager.style11Medium,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.open_in_new_rounded,
                color: AppColors.textSecondary, size: 15.sp),
          ],
        ),
      ),
    );
  }

  /// A single cell in the media grid.
  Widget _buildMediaCell(ChatMediaAttachment attachment) {
    if (attachment.isImage) {
      if (attachment.isLocal) {
        return Image.file(
          File(attachment.url),
          fit: BoxFit.cover,
          errorBuilder: (context, e1, e2) => Container(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.broken_image_rounded,
                color: AppColors.primary, size: 32.sp),
          ),
        );
      }
      return Image.network(
        attachment.url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.primary.withValues(alpha: 0.07),
            child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        },
        errorBuilder: (context, e1, e2) => Container(
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(Icons.broken_image_rounded,
              color: AppColors.primary, size: 32.sp),
        ),
      );
    } else if (attachment.isVideo) {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Icon(Icons.play_circle_fill_rounded,
              color: Colors.white.withValues(alpha: 0.85), size: 40.sp),
        ),
      );
    }
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Icon(Icons.insert_drive_file_rounded,
          color: AppColors.primary, size: 32.sp),
    );
  }

  /// Image bubble with full-screen viewer on tap. Handles both a server URL
  /// and a still-uploading local file.
  Widget _buildImageBubble(ChatMediaAttachment attachment) {
    final Widget errorBox = Container(
      width: 200.w,
      height: 200.w,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(Icons.broken_image_rounded,
          color: AppColors.primary, size: 40.sp),
    );

    return GestureDetector(
      onTap: () => _openMedia(attachment),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: attachment.isLocal
            ? Image.file(
                File(attachment.url),
                width: 200.w,
                height: 200.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) => errorBox,
              )
            : Image.network(
                attachment.url,
                width: 200.w,
                height: 200.w,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    width: 200.w,
                    height: 200.w,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, _) => errorBox,
              ),
      ),
    );
  }

  /// Video bubble — thumbnail placeholder + play icon.
  Widget _buildVideoBubble(ChatMediaAttachment attachment) {
    return GestureDetector(
      onTap: () => _openMedia(attachment),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200.w,
              height: 150.w,
              color: Colors.black87,
              child: Icon(Icons.videocam_rounded,
                  color: Colors.white.withValues(alpha: 0.3), size: 48.sp),
            ),
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded,
                  color: AppColors.primary, size: 32.sp),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the right full-screen viewer for [attachment], picking the local
  /// or the network variant depending on where the file lives.
  void _openMedia(ChatMediaAttachment attachment) {
    if (attachment.isImage) {
      attachment.isLocal
          ? _openImageViewer(attachment.url)
          : _openNetworkImageViewer(attachment.url);
    } else if (attachment.isVideo) {
      attachment.isLocal
          ? _openVideoViewer(attachment.url)
          : _openNetworkVideoViewer(attachment.url);
    } else {
      // PDF / document / anything else — native viewer first, in-app
      // WebView when no installed app can handle it.
      AttachmentOpener.open(context, url: attachment.url);
    }
  }

  /// Full-screen network image viewer.
  void _openNetworkImageViewer(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(12.w),
        child: GestureDetector(
          onTap: () => Navigator.pop(dialogCtx),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    height: 200.h,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Opens a network video using the existing [_VideoViewerDialog].
  void _openNetworkVideoViewer(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (_) => _NetworkVideoViewerDialog(url: url),
    );
  }

  /// Renders status tick marks matching WhatsApp style.
  Widget _buildWhatsAppStatusIcon(MessageStatus status) {
    final Color seenColor = const Color(0xFF34B7F1);
    final Color defaultColor = AppColors.textSecondary.withValues(alpha: 0.8);
    final Color iconColor =
        status == MessageStatus.seen ? seenColor : defaultColor;

    switch (status) {
      case MessageStatus.sent:
        return Icon(Icons.check, color: iconColor, size: 13.sp);
      case MessageStatus.delivered:
      case MessageStatus.seen:
        return Icon(Icons.done_all, color: iconColor, size: 14.sp);
      case MessageStatus.unknown:
        return Icon(Icons.access_time_rounded,
            color: defaultColor, size: 11.sp);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: const BoxDecoration(color: AppColors.backgroundTint),
      child: Column(
        children: [
          SizedBox(height: 30.h),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              final ChatLoaded? loaded = state is ChatLoaded ? state : null;
              final other = loaded?.otherParty;

              // Name/avatar handed over by the caller win, so the header is
              // already correct on the first frame; the messages response
              // fills them in for screens that open the chat directly.
              final String name = (widget.title?.isNotEmpty ?? false)
                  ? widget.title!
                  : ((other?.name.isNotEmpty ?? false)
                      ? other!.name
                      : 'conversations.dummy_name'.tr());
              final String? avatar = (widget.avatarUrl?.isNotEmpty ?? false)
                  ? widget.avatarUrl
                  : other?.avatar;
              final bool isOnline = widget.isAi || (other?.online ?? false);
              final bool isTyping = loaded?.isOtherPartyTyping ?? false;

              return Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.black,
                      size: 20.sp,
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 50.r,
                        height: 50.r,
                        padding: avatar != null && avatar.isNotEmpty
                            ? EdgeInsets.zero
                            : EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildHeaderAvatar(avatar),
                      ),
                      if (isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.backgroundTint,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyleManager.style14Bold.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        if (isTyping) ...[
                          SizedBox(height: 2.h),
                          Text(
                            'conversations.typing'.tr(),
                            style: TextStyleManager.heading3.copyWith(
                              color: AppColors.primary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Avatar shown in the header. Network pictures go through [AppImage], which
  /// renders them with a disk-cached image provider — re-entering the chat
  /// reuses the cached file instead of downloading it again.
  Widget _buildHeaderAvatar(String? avatar) {
    if (widget.isAi) return AppImage(AppImages.ai, fit: BoxFit.cover);
    if (avatar != null && avatar.isNotEmpty) {
      return AppImage(
        avatar,
        width: 50.r,
        height: 50.r,
        fit: BoxFit.cover,
        isAvatar: true,
      );
    }
    if (widget.isSpecialist) return AppImage(SvgIcons.logo, fit: BoxFit.cover);
    return Icon(Icons.person, color: AppColors.primary, size: 24.sp);
  }

  // ── Bubbles ────────────────────────────────────────────────────────────────

  Widget _buildBubble(_ChatMessage msg) {
    return Align(
      alignment:
          msg.isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment:
            msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () => _showReactionPicker(msg),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 0.72.sw),
                  padding: msg.kind == _MsgKind.text
                      ? EdgeInsets.all(16.w)
                      : EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: msg.isMe
                        ? AppColors.white
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r).copyWith(
                      topLeft: Radius.circular(msg.isMe ? 0 : 16.r),
                      topRight: Radius.circular(msg.isMe ? 16.r : 0),
                    ),
                    boxShadow: [
                      if (msg.isMe)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: _buildBubbleContent(msg),
                ),
                if (msg.reaction != null)
                  PositionedDirectional(
                    bottom: -10.h,
                    end: 8.w,
                    child: _reactionChip(msg.reaction!),
                  ),
              ],
            ),
          ),
          SizedBox(height: msg.reaction != null ? 14.h : 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (msg.isMe) ...[
                Icon(Icons.done_all, color: AppColors.primary, size: 14.sp),
                SizedBox(width: 4.w),
              ],
              Text(
                _fmtTime(msg.time),
                style: TextStyleManager.heading3.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reactionChip(String emoji) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(emoji, style: TextStyle(fontSize: 13.sp)),
    );
  }

  /// Long-press picker. Tapping an emoji sets it; tapping the one already on the
  /// message clears it. Local-only, nothing sent anywhere.
  void _showReactionPicker(_ChatMessage msg) {
    const emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(32.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: emojis.map((e) {
              final bool selected = msg.reaction == e;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() => msg.reaction = selected ? null : e);
                },
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                  child: Text(e, style: TextStyle(fontSize: 26.sp)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBubbleContent(_ChatMessage msg) {
    switch (msg.kind) {
      case _MsgKind.text:
        return Text(msg.text ?? '', style: TextStyleManager.style11Medium);

      case _MsgKind.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: GestureDetector(
            onTap: () => _openImageViewer(msg.path!),
            child: Image.file(
              File(msg.path!),
              width: 200.w,
              height: 200.w,
              fit: BoxFit.cover,
            ),
          ),
        );

      case _MsgKind.video:
        return GestureDetector(
          onTap: () => _openVideoViewer(msg.path!),
          child: Container(
            width: 200.w,
            height: 150.w,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow_rounded,
                    color: AppColors.primary, size: 30.sp),
              ),
            ),
          ),
        );

      case _MsgKind.audio:
        return _AudioBubble(path: msg.path!, isMe: msg.isMe);

      case _MsgKind.file:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file_rounded,
                  color: AppColors.primary, size: 28.sp),
              SizedBox(width: 10.w),
              Flexible(
                child: Text(
                  msg.fileName ?? 'conversations.attach_document'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleManager.style11Medium
                      .copyWith(color: AppColors.black),
                ),
              ),
            ],
          ),
        );
    }
  }

  void _openImageViewer(String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.file(File(path)),
          ),
        ),
      ),
    );
  }

  void _openVideoViewer(String path) {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.9),
      builder: (_) => _VideoViewerDialog(path: path),
    );
  }

  // ── Input area ─────────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: AppColors.backgroundTint,
      child: _isRecording ? _buildRecordingBar() : _buildComposerBar(),
    );
  }

  Widget _buildComposerBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendText(),
              decoration: InputDecoration(
                hintText: 'conversations.write_message_hint'.tr(),
                hintStyle: TextStyleManager.style10Medium.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          GestureDetector(
            onTap: _openAttachmentPanel,
            child: Icon(Icons.attach_file,
                color: AppColors.textSecondary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          // Mic when there's no text, send button once the user types.
          if (_hasText)
            GestureDetector(
              onTap: _sendText,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  'conversations.send'.tr(),
                  style: TextStyleManager.style11Medium
                      .copyWith(color: AppColors.white),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: _startRecording,
              child: Icon(Icons.mic, color: AppColors.textSecondary, size: 22.sp),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordingBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          // Cancel (delete)
          GestureDetector(
            onTap: _cancelRecording,
            child: Icon(Icons.delete_outline,
                color: AppColors.error, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 10.w,
            height: 10.w,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${'conversations.recording'.tr()}  ${_formatDuration(_recordSeconds)}',
            style: TextStyleManager.style11Medium
                .copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          // Stop & send
          GestureDetector(
            onTap: _stopAndSendRecording,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, color: AppColors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Audio message bubble — play/pause + progress + duration
// ─────────────────────────────────────────────────────────────────────────────
class _AudioBubble extends StatefulWidget {
  final String path;
  final bool isMe;
  /// When true, [path] is an HTTP URL; when false it's a local device file path.
  final bool isNetwork;

  const _AudioBubble({required this.path, required this.isMe, this.isNetwork = false});

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  /// The source is loaded on the first play instead of in [initState].
  /// Preloading every bubble spun up a native MediaPlayer (and an HTTP
  /// connection for remote clips) for each voice note the list scrolled past,
  /// which stuttered the scroll and threw "Bad state: No element" whenever the
  /// bubble was disposed mid-load.
  bool _sourceLoaded = false;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _ensureSource() async {
    if (_sourceLoaded) return;
    try {
      if (widget.isNetwork) {
        await _player.setSourceUrl(widget.path);
      } else {
        await _player.setSourceDeviceFile(widget.path);
      }
      _sourceLoaded = true;
    } catch (e) {
      debugPrint('[AudioBubble] ⚠️ could not load ${widget.path}: $e');
    }
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    await _ensureSource();
    if (!mounted) return;
    try {
      await _player.resume();
      if (mounted) setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint('[AudioBubble] ⚠️ playback failed: $e');
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_duration.inMilliseconds > 0)
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final Duration shown = _isPlaying || _position > Duration.zero
        ? _position
        : _duration;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Icon(
              _isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              color: AppColors.primary,
              size: 34.sp,
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 110.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4.h,
                    backgroundColor: AppColors.divider,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.mic, size: 12.sp, color: AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      _fmt(shown),
                      style: TextStyleManager.style10Medium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen local video viewer
// ─────────────────────────────────────────────────────────────────────────────
class _VideoViewerDialog extends StatefulWidget {
  final String path;

  const _VideoViewerDialog({required this.path});

  @override
  State<_VideoViewerDialog> createState() => _VideoViewerDialogState();
}

class _VideoViewerDialogState extends State<_VideoViewerDialog> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _controller.play();
        }
      });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.white, size: 26.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (!_initialized)
            SizedBox(
              height: 200.h,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio == 0
                    ? 16 / 9
                    : _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      child: AnimatedOpacity(
                        opacity: _controller.value.isPlaying ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.play_arrow,
                              color: AppColors.white, size: 34.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Network Video Viewer Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _NetworkVideoViewerDialog extends StatefulWidget {
  final String url;

  const _NetworkVideoViewerDialog({required this.url});

  @override
  State<_NetworkVideoViewerDialog> createState() =>
      _NetworkVideoViewerDialogState();
}

class _NetworkVideoViewerDialogState
    extends State<_NetworkVideoViewerDialog> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.url))
          ..initialize().then((_) {
            if (mounted) {
              setState(() => _initialized = true);
              _controller.play();
            }
          });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.white, size: 26.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (!_initialized)
            SizedBox(
              height: 200.h,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio == 0
                    ? 16 / 9
                    : _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      child: AnimatedOpacity(
                        opacity: _controller.value.isPlaying ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.play_arrow,
                              color: AppColors.white, size: 34.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}