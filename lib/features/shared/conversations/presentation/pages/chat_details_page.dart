import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

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

  const ChatDetailsPage({
    super.key,
    this.title,
    this.isAi = false,
    this.isSpecialist = false,
  });

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();

  final List<_ChatMessage> _messages = [];

  bool _hasText = false;

  // Recording state
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  String? _recordPath;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      final has = _messageController.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _seedInitialMessages();
  }

  /// Keeps the original two-bubble look so the screen isn't empty on open.
  void _seedInitialMessages() {
    final DateTime now = DateTime.now();
    _messages.addAll([
      _ChatMessage(
        kind: _MsgKind.text,
        isMe: false,
        time: now,
        text: widget.isAi || widget.isSpecialist
            ? 'conversations.dummy_welcome'.tr()
            : 'conversations.dummy_message_1'.tr(),
      ),
      _ChatMessage(
        kind: _MsgKind.text,
        isMe: true,
        time: now,
        text: widget.isAi || widget.isSpecialist
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
    super.dispose();
  }

  // ── Message helpers ────────────────────────────────────────────────────────

  void _addMessage(_ChatMessage msg) {
    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
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
    _addMessage(_ChatMessage(
      kind: _MsgKind.text,
      isMe: true,
      time: DateTime.now(),
      text: text,
    ));
  }

  // ── Attachments ────────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: source);
      if (file != null) {
        _addMessage(_ChatMessage(
          kind: _MsgKind.image,
          isMe: true,
          time: DateTime.now(),
          path: file.path,
        ));
      }
    } catch (_) {}
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickVideo(source: source);
      if (file != null) {
        _addMessage(_ChatMessage(
          kind: _MsgKind.video,
          isMe: true,
          time: DateTime.now(),
          path: file.path,
        ));
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
        _addMessage(_ChatMessage(
          kind: _MsgKind.file,
          isMe: true,
          time: DateTime.now(),
          path: picked!.path,
          fileName: picked.name,
        ));
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
                      onTap: () => _pickVideo(ImageSource.gallery),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('conversations.mic_permission_denied'.tr())),
          );
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
        _addMessage(_ChatMessage(
          kind: _MsgKind.audio,
          isMe: true,
          time: DateTime.now(),
          path: finalPath,
        ));
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
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LoaderHud(
        isCall: false,
        child: TopCenteredConstrainedBox(
          horizontalPadding: 0,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: const BoxDecoration(color: AppColors.backgroundTint),
      child: Column(
        children: [
          SizedBox(height: 30.h),
          Row(
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
                    width: 40.r,
                    height: 40.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.isAi
                        ? AppImage(AppImages.ai, fit: BoxFit.cover)
                        : (widget.isSpecialist
                            ? AppImage(SvgIcons.logo, fit: BoxFit.cover)
                            : Icon(Icons.person,
                                color: AppColors.primary, size: 24.sp)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10.w,
                      height: 10.h,
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
              Text(
                widget.title ?? 'conversations.dummy_name'.tr(),
                style: TextStyleManager.style14Bold.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  const _AudioBubble({required this.path, required this.isMe});

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.setSourceDeviceFile(widget.path);
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

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      await _player.play(DeviceFileSource(widget.path));
      if (mounted) setState(() => _isPlaying = true);
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
