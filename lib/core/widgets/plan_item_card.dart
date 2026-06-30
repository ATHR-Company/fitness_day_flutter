import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                SvgPicture.asset(SvgIcons.clock, height: 13.sp),
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
          if (showActions)
            Row(
              children: [
                // Edit Button (Green) - Right side in RTL
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
                      padding: EdgeInsets.symmetric(vertical: 8.h),
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
                          Icons.keyboard_double_arrow_left,
                          size: 16.sp,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                // Delete Button (Red) - Left side in RTL
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDeletePressed ?? () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
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
                          'visit_details.delete'
                              .tr()
                              .replaceAll('»', '')
                              .replaceAll('«', '')
                              .trim(),
                          style: TextStyleManager.smallButtons.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.keyboard_double_arrow_left,
                          size: 16.sp,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            // A button on the left (as in screenshot) if no actions? Wait. Image 2 has a single green button "تفاصيل" (Details) with arrows on the left!
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
                          'تفاصيل',
                          style: TextStyleManager.smallButtons.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.keyboard_double_arrow_left,
                          size: 16.sp,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
