import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import 'package:fitness_day/core/theme/app_colors.dart';

/// Full-screen video viewer used for both a device file and a remote URL.
///
/// ```dart
/// VideoViewerDialog.show(context, source: url, isNetwork: true);
/// ```
class VideoViewerDialog extends StatefulWidget {
  /// A device file path when [isNetwork] is false, otherwise an HTTP URL.
  final String source;
  final bool isNetwork;

  const VideoViewerDialog({
    super.key,
    required this.source,
    this.isNetwork = false,
  });

  /// Opens the viewer over a dimmed barrier.
  static Future<void> show(
    BuildContext context, {
    required String source,
    bool isNetwork = false,
  }) {
    return showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.9),
      builder: (_) => VideoViewerDialog(source: source, isNetwork: isNetwork),
    );
  }

  @override
  State<VideoViewerDialog> createState() => _VideoViewerDialogState();
}

class _VideoViewerDialogState extends State<VideoViewerDialog> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.source))
        : VideoPlayerController.file(File(widget.source));

    _controller
      ..addListener(_onControllerTick)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
        _controller.play();
      });
  }

  void _onControllerTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerTick);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
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
            _buildPlayer(),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    final double ratio = _controller.value.aspectRatio == 0
        ? 16 / 9
        : _controller.value.aspectRatio;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: AspectRatio(
        aspectRatio: ratio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            GestureDetector(
              onTap: _togglePlayback,
              child: AnimatedOpacity(
                opacity: _controller.value.isPlaying ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: AppColors.white,
                    size: 34.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
