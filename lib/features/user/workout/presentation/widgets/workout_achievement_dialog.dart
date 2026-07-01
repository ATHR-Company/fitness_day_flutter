import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

class WorkoutAchievementDialog extends StatelessWidget {
  const WorkoutAchievementDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, color: AppColors.primary, size: 24.sp),
              ),
            ),
            SizedBox(height: 16.h),
            
            // Icon
            Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.fitness_center, color: AppColors.primary, size: 60.sp),
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              LocaleKeys.workout_achievement_title.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.style16Bold.copyWith(color: AppColors.black),
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              LocaleKeys.workout_well_done.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.heading2.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 8.h),
            Text(
              LocaleKeys.workout_well_done_desc.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.style12Regular.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      LocaleKeys.workout_achievement_finish.tr(),
                      style: TextStyleManager.style14Bold.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    child: Text(
                      LocaleKeys.workout_achievement_continue.tr(),
                      style: TextStyleManager.style14Bold.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
