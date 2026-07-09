import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class ChallengeCreatedDialog extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onShare;

  const ChallengeCreatedDialog({
    super.key,
    required this.onStart,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFB5FFD9), // Light green gradient
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: InkWell(
                onTap: onStart, // Also close and proceed if X is clicked
                child: Icon(Icons.close, color: AppColors.primary, size: 28.sp),
              ),
            ),
            SizedBox(height: 16.h),
            
            // Icon
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F7EB), // Soft green circle
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  SvgIcons.muscle, // Muscle icon
                  width: 50.w,
                  height: 50.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              '" تم إنشاء التحدي بنجاح! "',
              textAlign: TextAlign.center,
              style: TextStyleManager.heading3.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            
            // Subtitle
            Text(
              'أرسل رابط التحدي لأصدقائك وابدأوا المنافسة!',
              textAlign: TextAlign.center,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onShare,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'مشاركة',
                      style: TextStyleManager.style13Medium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    child: Text(
                      'يلا نبدأ',
                      style: TextStyleManager.style13Medium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
