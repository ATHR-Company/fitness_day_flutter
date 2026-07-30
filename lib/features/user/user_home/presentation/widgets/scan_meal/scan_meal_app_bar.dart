import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Close button on the leading side with the screen title centred.
class ScanMealAppBar extends StatelessWidget {
  const ScanMealAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(
                Icons.close_rounded,
                size: 28.sp,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'scan_meal.title'.tr(),
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Balances the close button so the title stays optically centred.
          SizedBox(width: 36.w),
        ],
      ),
    );
  }
}
