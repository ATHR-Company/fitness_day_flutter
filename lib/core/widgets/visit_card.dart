import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class VisitCard extends StatelessWidget {
  final String timeRemaining;
  final String title;
  final String subtitle;
  final String clientName;
  final String visitTime;
  final String location;
  final VoidCallback onViewPressed;

  const VisitCard({
    super.key,
    required this.timeRemaining,
    required this.title,
    required this.subtitle,
    required this.clientName,
    required this.visitTime,
    required this.location,
    required this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF7FFF8),
            Color(0xFFEFFFF2),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(4.r),
          topEnd: Radius.circular(4.r),
          bottomStart: Radius.circular(4.r),
          bottomEnd: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                        SvgIcons.monitor,
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            subtitle,
                            style: TextStyleManager.style12Regular.copyWith(
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
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: SizedBox(
                    height: 36.h,
                    child: ElevatedButton(
                      onPressed: onViewPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                      ),
                      child: Text(
                        'visits.view_visit'.tr(),
                        style: TextStyleManager.style14Medium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7CD588),
                      Color(0xFFE6FFE9),
                      Color(0xFF7CD588),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadiusDirectional.only(
                    topEnd: Radius.circular(4.r),
                    bottomStart: Radius.circular(12.r),
                  ),
                ),
                child: Text(
                  timeRemaining,
                  style: TextStyleManager.style12Regular.copyWith(
                    color: AppColors.greenForest,
                    fontWeight: FontWeight.bold,
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
          style: TextStyleManager.style12Regular.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyleManager.style12Regular.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
