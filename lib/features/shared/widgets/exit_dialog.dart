import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEECEB), // Light red/pink
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Icon(Icons.close, color: AppColors.error, size: 24.sp),
                ),
              ],
            ),
          ),
          
          // Icon in the middle
          SizedBox(height: 32.h),
          Container(
            width: 100.r,
            height: 100.r,
            decoration: BoxDecoration(
              color: const Color(0xFFFEECEB),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.error, width: 2),
            ),
            child: Icon(
              Icons.exit_to_app_rounded,
              size: 40.sp,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 24.h),
          
          // Title
          Text(
            'تأكيد الخروج',
            style: TextStyleManager.heading2.copyWith(color: AppColors.black),
          ),
          SizedBox(height: 16.h),
          
          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'هل أنت متأكد أنك تريد الخروج من التطبيق؟',
              textAlign: TextAlign.center,
              style: TextStyleManager.style11Medium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 32.h),
          
          // Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'إلغاء',
                      style: TextStyleManager.style14Bold.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                      SystemNavigator.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'خروج',
                      style: TextStyleManager.style14Bold.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
