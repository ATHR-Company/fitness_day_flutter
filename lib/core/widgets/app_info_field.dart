import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
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
  final List<TextInputFormatter>? inputFormatters;

  /// Error shown under the field regardless of [validator] — used for
  /// server-side validation messages (`key` in the API error body).
  final String? errorText;

  const AppInfoField({
    super.key,
    required this.hint,
    this.iconPath,
    required this.controller,
    this.trailing,
    this.onTap,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFormatters = inputFormatters ??
        (keyboardType == TextInputType.number
            ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
            : null);
    return TextFormField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      validator: validator,
      // Not `decoration.errorText`: TextFormField rebuilds the decoration as
      // `decoration.copyWith(errorText: field.errorText)`, so a passing local
      // validator (null) silently wiped the server message and the field looked
      // fine after the server had rejected it. forceErrorText sits outside the
      // validator's result and is exactly what this is for.
      forceErrorText: errorText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: effectiveFormatters,
      textAlign: TextAlign.start,
      style: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: hint,
        errorStyle: TextStyleManager.style10Medium.copyWith(
          color: AppColors.error,
        ),
        errorMaxLines: 3,
        hintStyle: TextStyleManager.heading3.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconPath != null)
              AppImage(
                iconPath!,
                width: 20.w,
                height: 20.h,
                color: AppColors.textSecondary,
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
        prefixIconConstraints: BoxConstraints(
          minWidth: iconPath != null ? 36.w : 16.w,
          minHeight: 20.h,
        ),
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
