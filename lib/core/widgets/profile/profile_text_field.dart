import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/utils/no_script_input_formatter.dart';

class ProfileTextField extends StatelessWidget {
  final String hintText;
  final String iconPath;
  final bool isPassword;
  final bool nameOnly;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLength;

  const ProfileTextField({
    super.key,
    required this.hintText,
    required this.iconPath,
    this.isPassword = false,
    this.nameOnly = false,
    this.controller,
    this.keyboardType,
    this.maxLength,
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
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: AppImage(
              iconPath,
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
              keyboardType: keyboardType,
              // Name-only fields: allow letters + spaces + dot only.
              // Other free-text fields: strip script/HTML patterns.
              inputFormatters: isPassword
                  ? null
                  : nameOnly
                      ? [
                          NameInputFormatter(),
                          if (maxLength != null)
                            LengthLimitingTextInputFormatter(maxLength!),
                        ]
                      : [
                          NoScriptInputFormatter(),
                          if (maxLength != null)
                            LengthLimitingTextInputFormatter(maxLength!),
                        ],
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
