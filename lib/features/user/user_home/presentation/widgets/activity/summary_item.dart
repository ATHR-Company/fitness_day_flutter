import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Summary Item
// ─────────────────────────────────────────────────────────────────────────────

class SummaryItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final String unit;

  const SummaryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyleManager.dataCard.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 4.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyleManager.style16Bold
                    .copyWith(color: AppColors.primary),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyleManager.heading2.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
