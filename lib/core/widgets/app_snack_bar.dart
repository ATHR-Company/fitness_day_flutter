import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

SnackBar appSnackBar(
  BuildContext context, {
  required String text,
  bool isError = false,
  bool isSuccess = false,
}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    elevation: 8,
    margin: EdgeInsets.only(
      bottom: 30.h,
      right: 20.w,
      left: 20.w,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.r),
    ),
    duration: const Duration(milliseconds: 2500),
    backgroundColor: isError
        ? AppColors.error
        : isSuccess
            ? AppColors.success
            : AppColors.primary,
    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
    content: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyleManager.heading3.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

void showAppSnackBar(
  BuildContext context, {
  required String text,
  bool isError = false,
  bool isSuccess = false,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    appSnackBar(
      context,
      text: text,
      isError: isError,
      isSuccess: isSuccess,
    ),
  );
}
