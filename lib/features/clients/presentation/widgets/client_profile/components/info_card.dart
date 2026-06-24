import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final Map<String, String> data;
  final List<String> greenValues;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.data,
    this.greenValues = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Center(child: icon),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyleManager.style14Bold,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...data.entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text.rich(
                  TextSpan(
                    text: '${entry.key} : ',
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: entry.value,
                        style: TextStyleManager.style11Medium.copyWith(
                          color: greenValues.contains(entry.key) ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
