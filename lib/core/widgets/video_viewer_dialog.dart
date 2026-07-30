import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import 'package:fitness_day/core/theme/app_colors.dart';

/// Full-screen video player with play/pause, a scrubbable progress bar,
/// elapsed/total time, mute toggle and a close button. Controls auto-hide
/// while playing and reappear on tap.
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

  /// Pushes a full-screen, transparent-faded route that shows this player.
  static Future<void> show(
    BuildContext context, {
    required String source,
    bool isNetwork = false,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, _, _) =>
            VideoViewerDialog(source: source, isNetwork: isNetwork),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<VideoViewerDialog> createState() => _VideoViewerDialogState();
}

class _VideoViewerDialogState extends State<VideoViewerDialog> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _controlsVisible = true;
  bool _muted = false;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = widget.isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.source))
        : VideoPlayerController.file(File(widget.source));

    _controller
      ..addListener(_onControllerTick)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
        _controller.play();
        _scheduleHideControls();
      });
  }

  void _onControllerTick() {
    if (mounted) setState(() {});
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleHideControls();
  }

  void _togglePlayback() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _hideControlsTimer?.cancel();
    } else {
      _controller.play();
      _scheduleHideControls();
    }
    setState(() => _controlsVisible = true);
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _controller.setVolume(_muted ? 0 : 1);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0
        ? '${d.inHours}:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_onControllerTick);
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_initialized
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.white),
            )
          : GestureDetector(
              onTap: _toggleControls,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio == 0
                          ? 16 / 9
                          : _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),

                  if (_controller.value.isBuffering)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.white),
                    ),

                  // ── Top bar: close ─────────────────────────────────────
                  AnimatedOpacity(
                    opacity: _controlsVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: SafeArea(
                        child: Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Padding(
                            padding: EdgeInsets.all(8.r),
                            child: _ControlIconButton(
                              icon: Icons.close_rounded,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Center play/pause ──────────────────────────────────
                  AnimatedOpacity(
                    opacity: (_controlsVisible && !_controller.value.isPlaying)
                        ? 1
                        : 0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !(_controlsVisible &&
                          !_controller.value.isPlaying),
                      child: Center(
                        child: _ControlIconButton(
                          icon: Icons.play_arrow_rounded,
                          size: 40.sp,
                          padding: 16.r,
                          onTap: _togglePlayback,
                        ),
                      ),
                    ),
                  ),

                  // ── Bottom bar: play/pause, seek, time, mute ───────────
                  AnimatedOpacity(
                    opacity: _controlsVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: SafeArea(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: AppColors.white,
                                  ),
                                  onPressed: _togglePlayback,
                                ),
                                Text(
                                  _formatDuration(_controller.value.position),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 11.sp,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 6.w),
                                    child: VideoProgressIndicator(
                                      _controller,
                                      allowScrubbing: true,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      colors: VideoProgressColors(
                                        playedColor: AppColors.primary,
                                        bufferedColor:
                                            AppColors.white.withValues(alpha: 0.4),
                                        backgroundColor:
                                            AppColors.white.withValues(alpha: 0.2),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatDuration(_controller.value.duration),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 11.sp,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _muted
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    color: AppColors.white,
                                  ),
                                  onPressed: _toggleMute,
                                ),
                              ],
                            ),
                          ),
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

class _ControlIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double? size;
  final double? padding;

  const _ControlIconButton({
    required this.icon,
    required this.onTap,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding ?? 8.r),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: size ?? 22.sp,
        ),
      ),
    );
  }
}
