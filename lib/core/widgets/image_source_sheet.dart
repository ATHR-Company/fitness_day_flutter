import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom sheet that lets the user choose between camera and gallery.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   shape: RoundedRectangleBorder(
///     borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
///   ),
///   builder: (_) => ImageSourceSheet(
///     onCameraSelected: () { ... },
///     onGallerySelected: () { ... },
///   ),
/// );
/// ```
class ImageSourceSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;

  const ImageSourceSheet({
    super.key,
    required this.onCameraSelected,
    required this.onGallerySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            Text(
              'challenges.image_source_title'.tr(),
              style:
                  TextStyleManager.heading3.copyWith(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20.h),

            Row(
              children: [
                Expanded(
                  child: _SourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'challenges.camera'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      onCameraSelected();
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _SourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'challenges.gallery'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      onGallerySelected();
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

// ─── Source option tile ───────────────────────────────────────────────────────

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundTint,
          borderRadius: BorderRadius.circular(16.r),
          border:
              Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 30.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
