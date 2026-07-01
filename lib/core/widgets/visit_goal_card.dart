import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class VisitGoalCard extends StatelessWidget {
  final String title;
  final List<String> goals;

  const VisitGoalCard({super.key, required this.title, required this.goals});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title — right aligned, bold
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 10.h),

            // Goals list — NO DOTS, just right-aligned text
            ...goals.map(
              (goal) => Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Text(
                  goal,
                  textAlign: TextAlign.start,
                  
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
