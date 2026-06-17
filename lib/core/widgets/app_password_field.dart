import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  const AppPasswordField({
    super.key,
    this.controller,
    this.validator,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      validator: widget.validator,
      textAlign: TextAlign.right,
      style: TextStyleManager.heading3.copyWith(
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: 'login.password_hint'.tr(),
        hintStyle: TextStyleManager.heading3.copyWith(
          color: AppColors.textSecondary,
        ),
        // Suffix icon for the Lock, aligned on the right in RTL
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                SvgIcons.password,
                width: 24.w,
                height: 24.h,
                colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
              ),
              SizedBox(width: 12.w),
              // The grey vertical divider
              Container(
                width: 1.w,
                height: 24.h,
                color: AppColors.divider,
              ),
            ],
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: 48.w,
          minHeight: 24.h,
        ),
        // Password visibility toggle
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h),
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
