import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// Horizontal 7-day strip showing which days have appointments,
/// with the currently selected day highlighted.
class WeekCalendarStrip extends StatelessWidget {
  final List<DateTime> weekDays;
  final Set<String> appointmentDateKeys;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const WeekCalendarStrip({
    super.key,
    required this.weekDays,
    required this.appointmentDateKeys,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  static String dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(weekDays.length, (i) {
        final day = weekDays[i];
        final hasAppointment = appointmentDateKeys.contains(dateKey(day));
        final isSelected = i == selectedIndex && hasAppointment;
        final dayName =
            DateFormat.E(context.locale.languageCode).format(day);
        final dayNum = DateFormat.d('en').format(day);

        return Expanded(
          child: GestureDetector(
            onTap: hasAppointment ? () => onDaySelected(i) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : hasAppointment
                        ? AppColors.backgroundTint
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(14.r),
                border: hasAppointment && !isSelected
                    ? Border.all(
                        color: AppColors.greenMint,
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Day name
                  Text(
                    dayName,
                    style: TextStyleManager.style9Medium.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : hasAppointment
                              ? AppColors.textPrimary
                              : AppColors.divider,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Date number
                  Text(
                    dayNum,
                    style: TextStyleManager.style14Bold.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : hasAppointment
                              ? AppColors.black
                              : AppColors.divider,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Appointment dot indicator
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: hasAppointment && !isSelected ? 1.0 : 0.0,
                    child: Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
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
