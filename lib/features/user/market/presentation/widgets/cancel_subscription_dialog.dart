import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class CancelSubscriptionDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const CancelSubscriptionDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button Top Left
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  color: AppColors.primary,
                  size: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Big Green X Icon
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Confirmation Title
            Text(
              'هل أنت متأكد أنك تريد إلغاء الاشتراك في باقة صحي؟',
              textAlign: TextAlign.center,
              style: TextStyleManager.style13Medium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            // Warning Text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Icon(
                    Icons.error,
                    color: AppColors.error,
                    size: 22.sp,
                  ),
                ),
                  SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'تحذير : بعد الإلغاء، لن تصلك خطط التغذية اليومية أو نصائح النظام الغذائي .',
                    textAlign: TextAlign.start,
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
              
              
              ],
            ),
            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
              
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyleManager.style13Medium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                
                  Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: Text(
                        'رجوع',
                        style: TextStyleManager.style13Medium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
