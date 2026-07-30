import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';

/// Shutter button. Dims and stops responding while an analysis is running, so
/// a second photo can't be fired at the model mid-request.
class ScanMealCaptureButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onTap;

  const ScanMealCaptureButton({
    super.key,
    required this.isBusy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        width: 70.w,
        height: 70.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 4.w),
          color: AppColors.primary.withValues(alpha: isBusy ? 0.4 : 0.8),
        ),
        child: Icon(
          Icons.camera_alt_rounded,
          color: AppColors.white,
          size: 32.sp,
        ),
      ),
    );
  }
}
