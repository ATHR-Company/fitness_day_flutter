import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles/article_video_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Media Carousel — horizontal banner with dot indicators
// ─────────────────────────────────────────────────────────────────────────────
class MediaCarousel extends StatefulWidget {
  final List<ArticleMediaItem> items;
  final String fallbackImageUrl;
  final String title;

  const MediaCarousel({
    super.key,
    required this.items,
    required this.fallbackImageUrl,
    required this.title,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openVideoPlayer(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.8),
      builder: (_) => ArticleVideoDialog(
        videoUrl: videoUrl,
        title: widget.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          // ── Banner ──────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              height: 200.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isVideo = item.isVideo ||
                      item.url.toLowerCase().endsWith('.mp4') ||
                      item.url.toLowerCase().endsWith('.mov');
                  final imageUrl = isVideo ? widget.fallbackImageUrl : item.url;

                  return GestureDetector(
                    onTap: isVideo ? () => _openVideoPlayer(context, item.url) : null,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Image / video thumbnail
                        AppImage(
                          imageUrl,
                          height: 200.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        // Play button overlay — only for videos
                        if (isVideo)
                          Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.primary,
                              size: 32.sp,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Dot indicators ──────────────────────────────────────────────
          if (widget.items.length > 1) ...[
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.items.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: isActive ? 20.w : 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
