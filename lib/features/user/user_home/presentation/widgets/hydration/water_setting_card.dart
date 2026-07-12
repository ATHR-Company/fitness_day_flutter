import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// A single tappable "label: value" row shown on the water reminder
/// settings screen.
class WaterSettingCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const WaterSettingCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.hydrationAccent.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.hydrationAccent.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              value,
              style: TextStyleManager.heading3.copyWith(
                color: AppColors.hydrationAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
