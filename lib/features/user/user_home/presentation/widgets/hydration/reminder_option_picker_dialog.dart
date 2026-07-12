import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Generic grid-of-chips picker dialog, used for both the reminder interval
/// (minutes) and reminder count (times) pickers on the water reminder screen.
class ReminderOptionPickerDialog extends StatelessWidget {
  final String titleKey;
  final List<int> options;
  final int selectedValue;

  /// Translation key used to format each chip's label, e.g.
  /// `hydration.minutes_value` → `"{} دقائق"`.
  final String valueLabelKey;

  const ReminderOptionPickerDialog({
    super.key,
    required this.titleKey,
    required this.options,
    required this.selectedValue,
    required this.valueLabelKey,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titleKey.tr(),
              style: TextStyleManager.heading3.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              alignment: WrapAlignment.center,
              children: options.map((option) {
                final isSelected = selectedValue == option;
                return GestureDetector(
                  onTap: () => Navigator.pop(context, option),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.hydrationAccent : AppColors.hydrationBackground,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      valueLabelKey.tr(args: ['$option']),
                      style: TextStyleManager.style11Medium.copyWith(
                        color: isSelected ? AppColors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
