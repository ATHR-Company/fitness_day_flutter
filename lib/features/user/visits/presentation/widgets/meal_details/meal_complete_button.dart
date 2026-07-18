import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Full-width button to toggle a meal's completion state.
class MealCompleteButton extends StatelessWidget {
  final bool isCompleted;
  final bool isUpdating;
  final VoidCallback? onPressed;

  const MealCompleteButton({
    super.key,
    required this.isCompleted,
    required this.isUpdating,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: isUpdating ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? AppColors.divider : AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
        child: isUpdating
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isCompleted
                        ? LocaleKeys.meal_details_mark_incomplete.tr()
                        : LocaleKeys.meal_details_complete_meal.tr(),
                    style: TextStyleManager.style14Bold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
