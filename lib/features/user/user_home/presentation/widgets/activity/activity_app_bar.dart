import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared app bar builder
// ─────────────────────────────────────────────────────────────────────────────

Widget buildActivityAppBar(BuildContext context, String title) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
    child: Row(
      children: [
        GestureDetector(
          // maybePop, not pop: `Navigator.pop` bypasses PopScope outright, so
          // this button would have skipped the "finish the session first" guard
          // that the system back button goes through.
          onTap: () => Navigator.maybePop(context),
          child: Icon(Icons.arrow_back_ios_new,
              size: 20.sp, color: AppColors.black),
        ),
        const Spacer(),
        Text(
          title,
          style: TextStyleManager.heading2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        const Spacer(),
        SizedBox(width: 20.sp),
      ],
    ),
  );
}
