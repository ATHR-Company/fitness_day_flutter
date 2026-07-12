import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Shared "tap to open a picker" field used across the challenge creation
/// forms (challenge type, category, exercise name, etc). Direction-agnostic.
class ChallengeSelectionField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final VoidCallback onTap;

  const ChallengeSelectionField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? value! : hint,
                    style: TextStyleManager.style11Medium.copyWith(
                      color: hasValue ? AppColors.black : AppColors.borderGrey,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.borderGrey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
