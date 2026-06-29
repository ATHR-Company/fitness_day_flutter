import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class AppInfoField extends StatelessWidget {
  final String hint;
  final String? iconPath;
  final Widget? trailing;
  final TextEditingController controller;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;

  const AppInfoField({
    super.key,
    required this.hint,
    this.iconPath,
    required this.controller,
    this.trailing,
    this.onTap,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: keyboardType ?? TextInputType.text,
      textAlign: TextAlign.right,
      style: TextStyleManager.heading3.copyWith(
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyleManager.heading3.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconPath != null)
              SvgPicture.asset(
                iconPath!,
                width: 20.w,
                height: 20.h,
                colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
              )
            else
              Container(
                width: 2.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
          ],
        ),
        prefixIconConstraints: BoxConstraints(minWidth: iconPath != null ? 36.w : 16.w, minHeight: 20.h),
        suffixIcon: trailing != null
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: trailing,
              )
            : null,
        contentPadding: EdgeInsets.symmetric(vertical: 15.h),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1.0),
        ),
      ),
    );
  }
}
