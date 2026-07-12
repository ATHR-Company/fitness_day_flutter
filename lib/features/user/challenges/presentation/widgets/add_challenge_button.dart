import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class AddChallengeButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddChallengeButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
        gradient: AppColors.cardGradient,
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Text(
            'challenges.add_new'.tr(),
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.all(6.r),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'challenges.add_button'.tr(),
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Directionality.of(context) == ui. TextDirection.rtl
                        ? Icons.keyboard_double_arrow_left_rounded
                        : Icons.keyboard_double_arrow_right_rounded,
                    color: AppColors.white,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
        ],
      ),
    );
  }
}
