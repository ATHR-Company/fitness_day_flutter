import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A reusable vertical day tab bar extracted from VisitDetailsPage.
/// Displays a vertical list of day labels on the left side of the screen.
/// The selected day is highlighted with [AppColors.primary].
class VerticalDayTabBar extends StatelessWidget {
  /// List of day label strings to display.
  final List<String> days;

  /// Index of the currently selected day.
  final int selectedIndex;

  /// Callback invoked when the user taps a day tab.
  final void Function(int) onDaySelected;

  const VerticalDayTabBar({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        width: 60.w,
        decoration: BoxDecoration(
          color: AppColors.backgroundTint,
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(days.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onDaySelected(index),
              child: Container(
                height: 70.h,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: isSelected
                      ? BorderRadius.horizontal(right: Radius.circular(20.r))
                      : null,
                  border: !isSelected && index < days.length - 1
                      ? const Border(
                          bottom:
                              BorderSide(color: AppColors.white, width: 1),
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    days[index].replaceAll(' ', '\n'),
                    textAlign: TextAlign.center,
                    style: TextStyleManager.style10Medium.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
