import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';

class VisitCard extends StatelessWidget {
  final String timeRemaining;
  final String title;
  final String subtitle;
  final String clientName;
  final String visitTime;
  final String location;
  final String buttonText;
  final VoidCallback onViewPressed;
  final String iconPath;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const VisitCard({
    super.key,
    required this.timeRemaining,
    required this.title,
    required this.subtitle,
    required this.clientName,
    required this.visitTime,
    required this.location,
    required this.buttonText,
    required this.onViewPressed,
    this.iconPath = SvgIcons.monitor,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Icon + Title/Subtitle)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Monitor Icon in Circle
                    Center(
                      child: SvgPicture.asset(
                        iconPath,
                        width: 60.w,
                        height: 60.h,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyleManager.heading3.copyWith(
                              color: AppColors.black,
                              //fontWeight: FontWeight.bold,
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
                _buildDetailRow('visits.client_name_label'.tr(), clientName),
                SizedBox(height: 8.h),
                _buildDetailRow('visits.visit_time_label'.tr(), visitTime),
                SizedBox(height: 8.h),
                _buildDetailRow('visits.visit_location_label'.tr(), location),

                SizedBox(height: 16.h),
                // View Visit Button
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
                              buttonText.replaceAll('»', '').replaceAll('«', '').trim(),
                              style: TextStyleManager.style11Medium.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.keyboard_double_arrow_left, size: 16.sp, color: AppColors.white),
                          ],
                        ),
                      ),
                    ),
                    if (secondaryButtonText != null && onSecondaryPressed != null) ...[
                      SizedBox(width: 12.w),
                      SizedBox(
                        height: 36.h,
                        child: OutlinedButton(
                          onPressed: onSecondaryPressed,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                secondaryButtonText!.replaceAll('»', '').replaceAll('«', '').trim(),
                                style: TextStyleManager.style11Medium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.keyboard_double_arrow_left, size: 16.sp, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
