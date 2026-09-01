import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/utils/no_script_input_formatter.dart';

class ProfileTextField extends StatefulWidget {
  final String hintText;
  final String iconPath;
  final bool isPassword;
  final bool nameOnly;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLength;

  /// Replaces the default script/name formatters entirely — pass this when the
  /// field has its own idea of what a legal character is (e.g. digits only).
  final List<TextInputFormatter>? inputFormatters;

  /// Validation message shown under the field; `null` keeps it hidden.
  final String? errorText;

  const ProfileTextField({
    super.key,
    required this.hintText,
    required this.iconPath,
    this.isPassword = false,
    this.nameOnly = false,
    this.controller,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.errorText,
  });

  @override
  State<ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  /// Password fields start hidden; the eye in the suffix flips this, matching
  /// [AppPasswordField] on the auth screens.
  bool _obscure = true;

  /// The eye only appears once something has been typed — an empty field has
  /// nothing to reveal.
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.isPassword) {
      _hasText = widget.controller?.text.isNotEmpty ?? false;
      widget.controller?.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    if (widget.isPassword) {
      widget.controller?.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final bool hasText = widget.controller?.text.isNotEmpty ?? false;
    if (_hasText != hasText) setState(() => _hasText = hasText);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildField(hasError),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              widget.errorText!,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildField(bool hasError) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: hasError
              ? AppColors.error
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: AppImage(
              widget.iconPath,
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
              controller: widget.controller,
              obscureText: widget.isPassword && _obscure,
              keyboardType: widget.isPassword
                  ? TextInputType.visiblePassword
                  : widget.keyboardType,
              // Caller-supplied formatters win outright.
              // Name-only fields: allow letters + spaces + dot only.
              // Other free-text fields: strip script/HTML patterns.
              inputFormatters: widget.inputFormatters ??
                  (widget.isPassword
                      ? null
                      : widget.nameOnly
                          ? [
                              NameInputFormatter(),
                              if (widget.maxLength != null)
                                LengthLimitingTextInputFormatter(widget.maxLength!),
                            ]
                          : [
                              NoScriptInputFormatter(),
                              if (widget.maxLength != null)
                                LengthLimitingTextInputFormatter(widget.maxLength!),
                            ]),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                suffixIcon: widget.isPassword && _hasText
                    ? IconButton(
                        icon: AppImage(
                          _obscure ? SvgIcons.eyeClosed : SvgIcons.eye,
                          width: 20.w,
                          height: 20.h,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )
                    : null,
                suffixIconConstraints: BoxConstraints(
                  minWidth: 44.w,
                  minHeight: 24.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
