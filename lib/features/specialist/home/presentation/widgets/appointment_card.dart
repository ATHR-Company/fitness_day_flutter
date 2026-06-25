import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class AppointmentCard extends StatelessWidget {
  final bool isPastVisit;

  const AppointmentCard({
    super.key,
    this.isPastVisit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
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
          // Commitment Badge
          Align(
            alignment: AlignmentDirectional.topEnd, // Top left in RTL
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.greenMint, // Adjust to light green mint if needed
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(16.r),
                  bottomStart: Radius.circular(16.r),
                ),
              ),
              child: Text(
                "home.commitment_rate".tr(args: ['85']),
                style: TextStyleManager.style10Medium.copyWith(
                  color: AppColors.greenForest, // Dark green
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(SvgIcons.needMonitor, width: 70.w),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "home.weekly_follow_up".tr(),
                            style: TextStyleManager.style14Bold,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "home.weekly_follow_up_desc".tr(),
                            style: TextStyleManager.style11Medium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                
                // Details
                _buildDetailRow("home.client_name".tr(), "محمد عبدالله", true),
                SizedBox(height: 6.h),
                _buildDetailRow("home.visit_time".tr(), "اليوم 4:30 مساءا", true),
                SizedBox(height: 6.h),
                _buildDetailRow("home.last_visit".tr(), "منذ يومين", true), // For real data this should map appropriately
                
                SizedBox(height: 24.h),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Aligns to the left in RTL
                  children: [
                    if (!isPastVisit) ...[
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "home.reschedule".tr().replaceAll('»', '').trim(),
                              style: TextStyleManager.style11Medium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.keyboard_double_arrow_left, size: 16.sp, color: AppColors.primary),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                    ],
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isPastVisit 
                              ? 'clients_page.details'.tr().replaceAll('»', '').trim()
                              : "home.view_visit".tr().replaceAll('»', '').trim(),
                            style: TextStyleManager.style11Medium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.keyboard_double_arrow_left, size: 16.sp, color: AppColors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isValueGreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyleManager.style11Medium.copyWith(
            color: isValueGreen ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
