import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Full-width image carousel with dot indicators, favourite toggle, and share.
class ProductPhotoCarousel extends StatelessWidget {
  final List<String> photos;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final PageController pageController;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;

  /// True while the favourite request is in flight — shows a spinner in place
  /// of the heart, mirroring the product cards in the store list.
  final bool isTogglingFavorite;

  const ProductPhotoCarousel({
    super.key,
    required this.photos,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.pageController,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onShareTap,
    this.isTogglingFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // ── Photo pager ───────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                SizedBox(
                  height: 250.h,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: photos.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (_, i) => AppImage(
                      photos[i],
                      height: 250.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Favourite + Share buttons — leading edge
                PositionedDirectional(
                  top: 12.h,
                  start: 12.w,
                  child: Row(
                    children: [
                      _CarouselIconBtn(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        isFavorite ? AppColors.error : AppColors.primary,
                        onTap: onFavoriteTap,
                        busy: isTogglingFavorite,
                      ),
                      SizedBox(width: 8.w),
                      _CarouselIconBtn(
                        Icons.share,
                        AppColors.primary,
                        onTap: onShareTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Dot indicators ────────────────────────────────────────────
          if (photos.length > 1) ...[
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (i) {
                final bool active = i == selectedIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: active ? 20.w : 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.divider,
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

// ─── Small icon button used inside the carousel overlay ──────────────────────

class _CarouselIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool busy;

  const _CarouselIconBtn(this.icon, this.color, {this.onTap, this.busy = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: busy
            ? SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: color,
                ),
              )
            : Icon(icon, color: color, size: 20.sp),
      ),
    );
  }
}
