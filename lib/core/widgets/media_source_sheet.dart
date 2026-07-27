import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Bottom sheet that asks the user where the media should come from.
///
/// Returns the chosen [ImageSource], or `null` when the sheet is dismissed.
///
/// ```dart
/// final source = await showMediaSourceSheet(context);
/// if (source == null) return;
/// ```
Future<ImageSource?> showMediaSourceSheet(
  BuildContext context, {
  String titleKey = 'conversations.media_source_title',
  String cameraKey = 'conversations.attach_camera',
  String galleryKey = 'conversations.attach_gallery',
}) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetContext) => _MediaSourceSheet(
      titleKey: titleKey,
      cameraKey: cameraKey,
      galleryKey: galleryKey,
    ),
  );
}

class _MediaSourceSheet extends StatelessWidget {
  final String titleKey;
  final String cameraKey;
  final String galleryKey;

  const _MediaSourceSheet({
    required this.titleKey,
    required this.cameraKey,
    required this.galleryKey,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              titleKey.tr(),
              style: TextStyleManager.heading3
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _SourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: cameraKey.tr(),
                    onTap: () =>
                        Navigator.pop(context, ImageSource.camera),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _SourceOption(
                    icon: Icons.photo_library_rounded,
                    label: galleryKey.tr(),
                    onTap: () =>
                        Navigator.pop(context, ImageSource.gallery),
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
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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
