import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constant/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "home.measurements_review".tr(),
                      style: TextStyleManager.heading2.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "home.measurements_review_desc".tr(),
                      textAlign: TextAlign.right,
                      style: TextStyleManager.style12Regular.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: AppColors.greenSoftTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                padding: EdgeInsets.all(12.r),
                child: SvgPicture.asset(
                  SvgIcons.review, 
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Details
          _buildDetailRow("home.client_name".tr(), "محمد عبدالله", true),
          SizedBox(height: 8.h),
          _buildDetailRow("home.previous_visit_time".tr(), "10:30 مساءا  1/6/24", true),
          SizedBox(height: 8.h),
          _buildDetailRow("home.visit_location".tr(), "في مقر يوم الرشاقة", true),
          
          SizedBox(height: 20.h),
          
          // Button
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                elevation: 0,
              ),
              child: Text(
                "home.previous_visit".tr(),
                style: TextStyleManager.style12Regular.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isValueGreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyleManager.style12Regular.copyWith(
            color: isValueGreen ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyleManager.style12Regular.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
