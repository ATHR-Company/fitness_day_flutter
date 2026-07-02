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

  const ReportTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.suffixText,
    this.controller,
    this.keyboardType = TextInputType.number,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            //textAlign: TextAlign.right,
            style: TextStyleManager.heading3.copyWith(color: AppColors.black),
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
                borderSide: const BorderSide(
                  color: AppColors.divider,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: AppColors.divider,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
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
      ],
    );
  }
}
