import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Horizontal 7-day strip showing which days have appointments,
/// with the currently selected day highlighted.
class WeekCalendarStrip extends StatelessWidget {
  final List<DateTime> weekDays;

  /// Days with something on them: these get the tint, the border and the dot.
  final Set<String> appointmentDateKeys;

  /// Days the user may tap, when that is not the same thing as having content.
  ///
  /// The visit log has nothing to show for a day without an appointment, so it
  /// omits this and taps stay gated on [appointmentDateKeys]. The achievements
  /// screen does — a quiet day is a legitimate answer with its own empty
  /// state — so it passes all seven and lets the dot alone mark the days that
  /// earned a badge.
  final Set<String>? selectableDateKeys;

  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const WeekCalendarStrip({
    super.key,
    required this.weekDays,
    required this.appointmentDateKeys,
    required this.selectedIndex,
    required this.onDaySelected,
    this.selectableDateKeys,
  });

  static String dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(weekDays.length, (i) {
        final day = weekDays[i];
        final key = dateKey(day);
        final hasAppointment = appointmentDateKeys.contains(key);
        // Falls back to `hasAppointment`, so a caller that omits
        // `selectableDateKeys` behaves exactly as before.
        final isSelectable = selectableDateKeys?.contains(key) ?? hasAppointment;
        final isSelected = i == selectedIndex && isSelectable;
        final dayName =
            DateFormat.E(context.locale.languageCode).format(day);
        final dayNum = DateFormat.d('en').format(day);

        return Expanded(
          child: GestureDetector(
            onTap: isSelectable ? () => onDaySelected(i) : null,
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
                      // Greyed out only when the day cannot be opened at all —
                      // a selectable day with nothing on it is still readable.
                      color: isSelected
                          ? AppColors.white
                          : isSelectable
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
                          : isSelectable
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
