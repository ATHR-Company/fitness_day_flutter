import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class VisitGoalCard extends StatelessWidget {
  final String title;

  /// Optional line under the title — used by the client-notes card to say who
  /// the notes are actually for.
  final String? subtitle;

  final List<String> goals;
  final VoidCallback? onAddPressed;
  final VoidCallback? onEditPressed;

  const VisitGoalCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.goals,
    this.onAddPressed,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasGoals = goals.isNotEmpty;
    final showButton = (hasGoals && onEditPressed != null) || (!hasGoals && onAddPressed != null);

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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Left action button, Right title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.start,
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle!,
                          textAlign: TextAlign.start,
                          style: TextStyleManager.style9Medium.copyWith(
                            color: AppColors.textPrimary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showButton)
                  SizedBox(
                    height: 36.h,
                    child: ElevatedButton(
                      onPressed: hasGoals ? onEditPressed : onAddPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (hasGoals ? 'visit_details.edit_button' : 'visit_details.add_button')
                                .tr()
                                .replaceAll('»', '')
                                .replaceAll('«', '')
                                .trim(),
                            style: TextStyleManager.style11Medium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Directionality.of(context) == ui.TextDirection.rtl
                                ? Icons.keyboard_double_arrow_left
                                : Icons.keyboard_double_arrow_right,
                            size: 16.sp,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
            if (hasGoals) ...[
              SizedBox(height: 12.h),
              // Goals list
              ...goals.map(
                (goal) => Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
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
          ],
        ),
      ),
    );
  }
}
