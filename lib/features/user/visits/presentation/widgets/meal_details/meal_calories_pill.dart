import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pill showing "Calories <value> 🔥" beneath the meal name.
class MealCaloriesPill extends StatelessWidget {
  final double calories;

  const MealCaloriesPill({super.key, required this.calories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: AppColors.timeRemainingGradient,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.meal_details_calories_pill_label.tr(),
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            calories % 1 == 0 ? calories.toInt().toString() : calories.toStringAsFixed(1),
            style: TextStyleManager.style16Bold.copyWith(
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 8.w),
          Text('🔥', style: TextStyleManager.style16Bold),
        ],
      ),
    );
  }
}
