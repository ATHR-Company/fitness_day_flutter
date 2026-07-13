import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Circular icon + label button used on the hydration screen (the "1L" quick
/// add button, "manual" entry button, and reminder-time button).
class WaterActionButton extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final VoidCallback? onTap;
  final double size;

  const WaterActionButton({
    super.key,
    required this.iconWidget,
    required this.label,
    required this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: AppColors.hydrationBackground,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.hydrationBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.hydrationAccent.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 9.sp,

                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
