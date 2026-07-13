import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? measurement;
  final String iconPath;
  final bool isCircle;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.measurement,
    required this.iconPath,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppImage(
                    iconPath,
                    color: AppColors.primary,
                  ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyleManager.style14Bold.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (measurement != null) ...[
                SizedBox(width: 4.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Text(
                    measurement!,
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
