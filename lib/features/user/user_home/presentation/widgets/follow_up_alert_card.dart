import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_shadows.dart';

class FollowUpAlertCard extends StatelessWidget {
  final String title;
  final String clientName;
  final String alertReason;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String iconPath;

  const FollowUpAlertCard({
    super.key,
    required this.title,
    required this.clientName,
    required this.alertReason,
    required this.buttonText,
    required this.onButtonPressed,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
        ),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(iconPath),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyleManager.style14Bold.copyWith(
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Details
          _buildDetailRow('visits.client_name_label'.tr(), clientName, AppColors.primary),
          SizedBox(height: 8.h),
          _buildDetailRow('home.alert_reason'.tr(), alertReason, AppColors.error),
          
          SizedBox(height: 24.h),
          
          // Button
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              height: 36.h,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleManager.style9Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            value,
            style: TextStyleManager.style9Medium.copyWith(
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
