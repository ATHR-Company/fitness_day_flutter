import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String iconPath;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Column(
        children: [
          AppImage(iconPath, width: 45.w, height: 45.w),
          SizedBox(height: 6.h),
          Text(
            title,
            style: TextStyleManager.style9Medium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyleManager.heading2.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
