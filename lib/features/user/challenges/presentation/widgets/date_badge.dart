import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class DateBadge extends StatelessWidget {
  final String label;
  final bool isEnd;

  const DateBadge({super.key, required this.label, required this.isEnd});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.textSecondary, width: 1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            isEnd ? 'challenges.date_end'.tr() : 'challenges.date_start'.tr(),
            style: TextStyleManager.style7Medium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyleManager.style8Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
