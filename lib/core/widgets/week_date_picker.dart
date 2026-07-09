import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
class WeekDatePicker extends StatelessWidget {
  final List<String> days;
  final List<String> dates;
  final int selectedIndex;
  final Set<int> doneDayIndices;
  final ValueChanged<int> onDaySelected;

  const WeekDatePicker({
    super.key,
    required this.days,
    required this.dates,
    required this.selectedIndex,
    required this.onDaySelected,
    this.doneDayIndices = const {},
  }) : assert(days.length == dates.length,
            'days and dates must have the same length');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (i) {
        final isSelected = i == selectedIndex;
        final isDone = doneDayIndices.contains(i);

        return Expanded(
          child: GestureDetector(
            onTap: () => onDaySelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              padding: EdgeInsets.all(5.r),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Day label ──────────────────────────────────────
                  Text(
                    days[i],
                    style: TextStyleManager.style9Medium.copyWith(
                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // ── Date or done indicator ─────────────────────────
                  if (isDone && !isSelected)
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColors.white,
                        size: 16.sp,
                      ),
                    )
                  else
                    Text(
                      dates[i],
                      style: TextStyleManager.style14Bold.copyWith(
                        color: isSelected ? AppColors.white : AppColors.black,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
