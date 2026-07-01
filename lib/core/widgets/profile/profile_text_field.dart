import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class ProfileTextField extends StatelessWidget {
  final String hintText;
  final String iconPath;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const ProfileTextField({
    super.key,
    required this.hintText,
    required this.iconPath,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SvgPicture.asset(
              iconPath,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
              width: 20.w,
            ),
          ),
          Container(
            height: 24.h,
            width: 1.5.w,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              textAlign: TextAlign.right,
              keyboardType: keyboardType,
              textDirection: ui.TextDirection.rtl,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
