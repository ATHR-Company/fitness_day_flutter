import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// "Align the food inside the frame", shown under the viewfinder.
///
/// It used to sit inside the preview overlay, where the shutter button was
/// drawn straight over it; on the page background it is legible without a
/// text shadow to fight the camera image.
class ScanMealHint extends StatelessWidget {
  const ScanMealHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Text(
        'scan_meal.align_hint'.tr(),
        textAlign: TextAlign.center,
        style: TextStyleManager.style11Medium.copyWith(
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}
