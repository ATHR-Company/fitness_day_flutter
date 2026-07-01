import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutPauseDialog extends StatelessWidget {
  final VoidCallback onEnd;
  final VoidCallback onContinue;

  const WorkoutPauseDialog({
    super.key,
    required this.onEnd,
    required this.onContinue,
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
              Color(0xFFB5FFD9), // Light green
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: InkWell(
                onTap: onContinue,
                child: Icon(Icons.close, color: const Color(0xFF00A900), size: 32.sp),
              ),
            ),
            SizedBox(height: 16.h),
            
            // Icon
            SvgPicture.asset(
              SvgIcons.workoutPopup,
              width: 120.r,
              height: 120.r,
            ),
            SizedBox(height: 32.h),

            // Description
            Text(
              'كمّل دلوقتي... الإنجاز على بعد خطوة!',
              textAlign: TextAlign.center,
              style: TextStyleManager.style16Bold.copyWith(
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 32.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEnd,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00A900),
                      side: const BorderSide(color: Color(0xFF00A900)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'انهاء',
                      style: TextStyleManager.style14Bold.copyWith(color: const Color(0xFF00A900)),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A900),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    child: Text(
                      'يلا نكمل',
                      style: TextStyleManager.style14Bold.copyWith(color: AppColors.white),
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
