import 'dart:ui' as ui;

import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class PlanItemCard extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final String? time;
  final String? subtitle;
  final Widget details;
  final bool showActions;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const PlanItemCard({
    super.key,
    required this.title,
    required this.isCompleted,
    this.time,
    this.subtitle,
    required this.details,
    this.showActions = false,
    this.onEditPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: AppShadows.primaryShadow,
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(child: Text(title, style: TextStyleManager.heading3)),
              if (time != null) ...[
                AppImage(SvgIcons.clock, height: 13.sp),
                SizedBox(width: 4.w),
                Text(
                  time!,
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
              const SizedBox(width: 7),
              Icon(
                Icons.check_circle_rounded,
                color: isCompleted ? AppColors.primary : AppColors.divider,
                size: 22.sp,
              ),
            ],
          ),

          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],

          SizedBox(height: 12.h),
          details,
          SizedBox(height: 16.h),

          // Bottom Buttons
          // الحالة 1: showActions = false → زرار "تفاصيل"
          if (!showActions)
            Row(
              children: [
                const Spacer(),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'visit_details.details'
                              .tr()
                              .replaceAll('»', '')
                              .replaceAll('«', '')
                              .trim(),
                          style: TextStyleManager.smallButtons.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2.w),
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
                ),
              ],
            )
          // الحالة 2: showActions = true و isCompleted = false → زرار "تعديل"
          else if (!isCompleted)
            Row(
              children: [
                SizedBox(width: 0.w),
                const Spacer(),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onEditPressed ?? () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'visit_details.edit'
                              .tr()
                              .replaceAll('»', '')
                              .replaceAll('«', '')
                              .trim(),
                          style: TextStyleManager.smallButtons.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2.w),
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
                ),
              ],
            ),
          // الحالة 3: showActions = true و isCompleted = true → لا شيء (مخفي)
        ],
      ),
    );
  }
}
