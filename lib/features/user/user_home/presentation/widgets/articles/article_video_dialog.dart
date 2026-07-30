import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Article Video Player Dialog
// ─────────────────────────────────────────────────────────────────────────────
class ArticleVideoDialog extends StatefulWidget {
  final String videoUrl;
  final String title;

  const ArticleVideoDialog({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<ArticleVideoDialog> createState() => _ArticleVideoDialogState();
}

class _ArticleVideoDialogState extends State<ArticleVideoDialog> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        }
      }).catchError((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.black,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyleManager.style13Medium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.white, size: 22.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Player Area
            Container(
              color: AppColors.black,
              constraints: BoxConstraints(maxHeight: 380.h),
              child: _hasError
                  ? SizedBox(
                      height: 200.h,
                      child: Center(
                        child: Text(
                          'خطأ في تحميل الفيديو',
                          style: TextStyleManager.style12Regular.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    )
                  : !_isInitialized
                      ? SizedBox(
                          height: 200.h,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: _controller.value.aspectRatio > 0
                              ? _controller.value.aspectRatio
                              : 16 / 9,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_controller),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_controller.value.isPlaying) {
                                      _controller.pause();
                                    } else {
                                      _controller.play();
                                    }
                                  });
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: AnimatedOpacity(
                                      opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Container(
                                        padding: EdgeInsets.all(16.r),
                                        decoration: BoxDecoration(
                                          color: AppColors.black.withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _controller.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: AppColors.white,
                                          size: 36.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
            // Progress & Controls
            if (_isInitialized && !_hasError) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                          style: TextStyleManager.style10Medium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isMuted ? Icons.volume_off : Icons.volume_up,
                            color: AppColors.white,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            setState(() {
                              _isMuted = !_isMuted;
                              _controller.setVolume(_isMuted ? 0.0 : 1.0);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
