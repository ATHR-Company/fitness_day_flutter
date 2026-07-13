import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Confirmation dialog shown when the user tries to leave the reminder
/// settings screen with unsaved changes.
///
/// Returns `true` (save), `false` (discard), or `null` (stay) via
/// `Navigator.pop`.
class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.hydrationAccent.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(SvgIcons.water_bg, width: 80.w, height: 80.h),
            SizedBox(height: 33.h),
            Text(
              'hydration.save_changes_title'.tr(),
              style: TextStyleManager.heading3.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'hydration.unsaved_changes_body'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.style11Medium.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 50.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.hydrationBackground,
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'hydration.discard'.tr(),
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.hydrationAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.hydrationAccent,
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'hydration.save'.tr(),
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
