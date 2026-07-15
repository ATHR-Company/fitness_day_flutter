import 'dart:ui' as ui;
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';

class VisitCard extends StatelessWidget {
  final String timeRemaining;
  final String title;
  final String subtitle;
  final String personName;
  final String? personNameLabel;
  final String visitTime;
  final String location;
  final String buttonText;
  final VoidCallback onViewPressed;
  final String iconPath;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final bool showButton;
  final Color? iconColor;
  final bool isCompleted;
  final bool isUpcoming;
  final bool canChangePlaceOrTime;
  final VoidCallback? onReschedulePressed;
  final VoidCallback? onChangeLocationPressed;

  const VisitCard({
    super.key,
    required this.timeRemaining,
    required this.title,
    required this.subtitle,
    required this.personName,
    this.personNameLabel,
    required this.visitTime,
    required this.location,
    required this.buttonText,
    required this.onViewPressed,
    this.iconPath = SvgIcons.monitor,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.showButton = true,
    this.iconColor,
    this.isCompleted = false,
    this.isUpcoming = false,
    this.canChangePlaceOrTime = false,
    this.onReschedulePressed,
    this.onChangeLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(4.r),
          topEnd: Radius.circular(4.r),
          bottomStart: Radius.circular(4.r),
          bottomEnd: Radius.circular(32.r),
        ),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Icon + Title/Subtitle)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Monitor Icon in Circle
                    AppImage(
                      iconPath,
                    ),
                    SizedBox(width: 5.w),
                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyleManager.heading3.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            subtitle,
                            style: TextStyleManager.style9Medium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Details Rows
                _buildDetailRow(
                    personNameLabel ?? 'visits.client_name_label'.tr(),
                    personName),
                SizedBox(height: 8.h),
                _buildDetailRow('visits.visit_time_label'.tr(), visitTime),
                SizedBox(height: 8.h),
                _buildDetailRow('visits.visit_location_label'.tr(), location),

                SizedBox(height: 16.h),
                // View Visit Button
                if (showButton)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 36.h,
                        child: ElevatedButton(
                          onPressed: onViewPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                buttonText
                                    .replaceAll('»', '')
                                    .replaceAll('«', '')
                                    .trim(),
                                style: TextStyleManager.style11Medium.copyWith(
                                  color: AppColors.white,
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
                      ),
                    ],
                  ),
                
                // Extra actions for change place/time
                if (canChangePlaceOrTime && isUpcoming) ...[
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReschedulePressed,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                          child: Text(
                            'إعادة جدولة',
                            style: TextStyleManager.style11Medium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onChangeLocationPressed,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                          child: Text(
                            'تغيير المكان',
                            style: TextStyleManager.style11Medium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Top Left Badge (Optional)
          if (timeRemaining.isNotEmpty)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: AppColors.timeRemainingGradient,
                  boxShadow: AppShadows.primaryShadow,
                  borderRadius: BorderRadiusDirectional.only(
                    topEnd: Radius.circular(4.r),
                    bottomStart: Radius.circular(12.r),
                  ),
                ),
                child: Text(
                  timeRemaining,
                  style: TextStyleManager.style8Bold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          
          // if (isCompleted)
            // PositionedDirectional(
            //   start: 16.w,
            //   top: 30.h,
            //   child: Container(
            //     padding: EdgeInsets.all(4.w),
            //     decoration: const BoxDecoration(
            //       color: AppColors.primary,
            //       shape: BoxShape.circle,
            //     ),
            //     child: Icon(Icons.check, color: AppColors.white, size: 16.sp),
            //   ),
            // ),
            
          // if (isUpcoming)
          //   PositionedDirectional(
          //     start: 16.w,
          //     top: 30.h,
          //     child: Container(
          //       padding: EdgeInsets.all(4.w),
          //       decoration: const BoxDecoration(
          //         color: Colors.grey,
          //         shape: BoxShape.circle,
          //       ),
          //       child: Icon(Icons.check, color: AppColors.white, size: 16.sp),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyleManager.style9Medium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyleManager.style9Medium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
