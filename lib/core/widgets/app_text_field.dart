import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/utils/no_script_input_formatter.dart';

class AppFieldLabel extends StatelessWidget {
  final String text;

  const AppFieldLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyleManager.style11Medium,
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String hintText;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final Color? valueColor;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final bool filled;
  final Color? fillColor;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry? contentPadding;

  const AppTextField({
    super.key,
    required this.hintText,
    this.suffixIcon,
    this.onTap,
    this.controller,
    this.valueColor,
    this.validator,
    this.readOnly = false,
    this.filled = true,
    this.fillColor = AppColors.white,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly || onTap != null,
      onTap: onTap,
      validator: validator,
      textAlign: textAlign,
      keyboardType: keyboardType,
      // Strip HTML/script injection patterns unless the field is read-only
      // or numeric (numeric keyboards can't type tags anyway).
      inputFormatters: (readOnly || onTap != null)
          ? null
          : [NoScriptInputFormatter()],
      style: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyleManager.style10Medium.copyWith(
          color: valueColor ?? AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        fillColor: fillColor,
        filled: filled,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
