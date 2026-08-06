import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import 'package:fitness_day/core/theme/app_colors.dart';

/// Shows the video's first frame as a static preview, with a play badge on
/// top — used in place of a flat placeholder so the user sees what the clip
/// actually looks like before opening it.
class ChatVideoThumbnail extends StatefulWidget {
  final String source;
  final bool isNetwork;
  final double? playIconSize;

  const ChatVideoThumbnail({
    super.key,
    required this.source,
    required this.isNetwork,
    this.playIconSize,
  });

  @override
  State<ChatVideoThumbnail> createState() => _ChatVideoThumbnailState();
}

class _ChatVideoThumbnailState extends State<ChatVideoThumbnail> {
  VideoPlayerController? _controller;
  bool _frameReady = false;

  /// Bumped on every (re)load. An `initialize()` that finishes after the widget
  /// was pointed at a different clip carries a stale generation and is dropped
  /// instead of being painted over the current one.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// The list recycles this State between messages — sending several videos in
  /// a row hands the same element a new [ChatVideoThumbnail.source], and the
  /// optimistic bubble also swaps its local path for the server URL once the
  /// upload lands. Without this the old controller stayed on screen, so a clip
  /// showed the previous clip's first frame until the chat was reopened.
  @override
  void didUpdateWidget(covariant ChatVideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source == widget.source &&
        oldWidget.isNetwork == widget.isNetwork) {
      return;
    }
    _disposeController();
    setState(() => _frameReady = false);
    _init();
  }

  Future<void> _init() async {
    final int generation = ++_generation;
    final controller = widget.isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.source))
        : VideoPlayerController.file(File(widget.source));
    _controller = controller;
    try {
      await controller.initialize();
      // Paused on the first frame — this IS the thumbnail, nothing plays.
      await controller.pause();
      await controller.seekTo(Duration.zero);
      if (!mounted || generation != _generation) return;
      setState(() => _frameReady = true);
    } catch (_) {
      // Leave the fallback background showing.
    }
  }

  void _disposeController() {
    _generation++;
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: Container(color: Colors.black87)),
        if (_frameReady && _controller != null)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        Container(
          width: (widget.playIconSize ?? 52).r,
          height: (widget.playIconSize ?? 52).r,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppColors.primary,
            size: ((widget.playIconSize ?? 52) * 0.6).sp,
          ),
        ),
      ],
    );
  }
}
