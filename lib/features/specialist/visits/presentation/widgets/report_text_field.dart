import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';

class ReportTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? suffixText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? errorText;
  final GlobalKey? fieldKey;

  const ReportTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.suffixText,
    this.controller,
    this.keyboardType = TextInputType.number,
    this.errorText,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      key: fieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleManager.style10Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: AppShadows.primaryShadow,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyleManager.style9Medium.copyWith(
                color: AppColors.divider,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.divider,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.divider,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.primary,
                  width: 1.0,
                ),
              ),
              suffixIcon: suffixText != null
                  ? IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Container(
                              width: 1.w,
                              color: AppColors.divider,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Center(
                              child: Text(
                                suffixText!,
                                style: TextStyleManager.style9Medium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
              suffixIconConstraints: BoxConstraints(minHeight: 24.h),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              errorText!,
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
