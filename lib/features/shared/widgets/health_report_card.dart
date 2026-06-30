import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class HealthReportCard extends StatelessWidget {
  const HealthReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.primary.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Center(
              child: Text(
                'تقريرك الصحي',
                style: TextStyleManager.heading2.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Data Rows
          _buildRow('الوزن :', '58.4', unit: 'كجم', isEven: false),
          _buildRow('الطول :', '167', unit: 'سم', isEven: true),
          _buildRow('BMI :', '22.0', unit: 'طبيعي', isEven: false),
          _buildRow('معدل الحرق :', '1284.4', isEven: true),
          _buildRow('وزن الدهون :', '15.7', unit: 'كجم', isEven: false),
          _buildRow('نسبة الدهون :', '24%', isEven: true),
          _buildRow('وزن العضلات :', '3.7', unit: 'كجم', isEven: false),
          _buildRow('نسبة العضلات :', '24%', isEven: true),
          _buildRow('البروتين :', '17.8', isEven: false, isLast: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {String? unit, required bool isEven, bool isLast = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isEven ? AppColors.backgroundTint : AppColors.white,
        borderRadius: isLast ? BorderRadius.vertical(bottom: Radius.circular(16.r)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: 4.w),
                Text(
                  unit,
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
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
