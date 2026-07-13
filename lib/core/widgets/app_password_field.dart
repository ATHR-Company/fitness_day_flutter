import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final String? hint;

  const AppPasswordField({
    super.key,
    this.controller,
    this.validator,
    this.hint,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;
  bool _hasText = false;
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);

    _focusNode.addListener(() {
      setState(() {});
    });
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final iconColor = (isFocused || _hasText)
        ? AppColors.primary
        : AppColors.textSecondary;
    final dividerColor = (isFocused || _hasText)
        ? AppColors.primary
        : AppColors.divider;

    return TextFormField(
      focusNode: _focusNode,
      controller: _controller,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textAlign: TextAlign.start,
      style: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: widget.hint ?? 'login.password_hint'.tr(),
        hintStyle: TextStyleManager.heading3.copyWith(
          color: AppColors.textSecondary,
        ),
        // Suffix icon for the Lock, aligned on the right in RTL
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppImage(
                SvgIcons.password,
                width: 24.w,
                height: 24.h,
                color: iconColor,
              ),
              SizedBox(width: 12.w),
              // The vertical divider
              Container(width: 1.w, height: 24.h, color: dividerColor),
            ],
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 48.w, minHeight: 24.h),
        // Password visibility toggle (only visible when there is text)
        suffixIcon: _hasText
            ? IconButton(
                icon: AppImage(
                  _obscureText ? SvgIcons.eyeClosed : SvgIcons.eye,
                  width: 20.w,
                  height: 20.h,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
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
