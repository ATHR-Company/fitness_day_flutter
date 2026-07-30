import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/rewards/data/models/check_in_calendar_models.dart';

/// The monthly check-in grid, rendered straight from
/// `GET /daily-check-in/calendar`.
///
/// The response always carries every day of the month, so nothing is generated
/// here — the widget only decides where the first cell sits and which icon each
/// day gets.
class CheckInCalendar extends StatelessWidget {
  final CheckInCalendarModel calendar;
  final ValueChanged<int>? onMonthChanged;

  const CheckInCalendar({
    super.key,
    required this.calendar,
    this.onMonthChanged,
  });

  // LTR column order: Sat Sun Mon Tue Wed Thu Fri (index 0→6)
  static const List<String> _ltrHeaders = [
    'common.weekdays.sat',
    'common.weekdays.sun',
    'common.weekdays.mon',
    'common.weekdays.tue',
    'common.weekdays.wed',
    'common.weekdays.thu',
    'common.weekdays.fri',
  ];

  /// Column of the month's first day in a Saturday-first grid.
  ///
  /// Built with `DateTime.utc`, not a local `DateTime`: the API day is a plain
  /// `YYYY-MM-DD` calendar date, and parsing it locally would shift it for
  /// anyone behind UTC.
  int get _startOffset {
    final CheckInCalendarDayModel first = calendar.days.first;
    final DateTime firstDate = DateTime.utc(
      calendar.year,
      calendar.month,
      first.dayOfMonth,
    );
    // DateTime.weekday: Mon = 1 … Sun = 7. Saturday-first column index:
    // Sat → 0, Sun → 1, Mon → 2 … Fri → 6.
    return (firstDate.weekday + 1) % 7;
  }

  /// A day the user simply hasn't reached yet. `checkedIn` is `false` for those
  /// exactly as it is for missed days, so without this every remaining day of
  /// the month would be painted as a miss. Compared in UTC because that is the
  /// day boundary the backend uses.
  bool _isFuture(CheckInCalendarDayModel day) {
    final DateTime today = DateTime.now().toUtc();
    final DateTime todayDate = DateTime.utc(today.year, today.month, today.day);
    return DateTime.utc(calendar.year, calendar.month, day.dayOfMonth)
        .isAfter(todayDate);
  }

  @override
  Widget build(BuildContext context) {
    if (calendar.days.isEmpty) return const SizedBox.shrink();

    final int startOffset = _startOffset;
    final int totalCells = startOffset + calendar.days.length;
    final int rowCount = (totalCells / 7).ceil();

    final List<Widget> gridRows = [];
    for (int row = 0; row < rowCount; row++) {
      final List<Widget> cells = [];
      for (int col = 0; col < 7; col++) {
        final int dayIndex = row * 7 + col - startOffset;
        cells.add(
          Expanded(
            child: (dayIndex < 0 || dayIndex >= calendar.days.length)
                ? const SizedBox()
                : _DayCell(
                    day: calendar.days[dayIndex],
                    isFuture: _isFuture(calendar.days[dayIndex]),
                  ),
          ),
        );
      }
      gridRows.add(Row(children: cells));
    }

    final List<Widget> headers = _ltrHeaders
        .map(
          (key) => Expanded(
            child: Center(
              child: Text(
                key.tr(),
                style: TextStyleManager.style10Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        )
        .toList();

    return Column(
      children: [
        _MonthHeader(
          year: calendar.year,
          month: calendar.month,
          checkedInDays: calendar.checkedInDays,
          totalPoints: calendar.totalPoints,
          onMonthChanged: onMonthChanged,
        ),
        SizedBox(height: 8.h),
        // Wrap in LTR so the grid's internal logic is always Sat-at-col-0. The
        // outer Directionality (app locale) mirrors the whole widget for
        // Arabic, putting col-0 on the right.
        Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Column(
            children: [
              Row(children: headers),
              SizedBox(height: 8.h),
              ...gridRows,
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final int year;
  final int month;
  final int checkedInDays;
  final int totalPoints;
  final ValueChanged<int>? onMonthChanged;

  const _MonthHeader({
    required this.year,
    required this.month,
    required this.checkedInDays,
    required this.totalPoints,
    this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    // `month` is 1-based; DateTime.utc keeps the label off the device clock.
    final String label = DateFormat.yMMMM(context.locale.languageCode)
        .format(DateTime.utc(year, month));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onMonthChanged == null ? null : () => onMonthChanged!(-1),
          icon: Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 22.sp),
        ),
        Column(
          children: [
            Text(
              label,
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'awards.month_summary'.tr(
                args: ['$checkedInDays', '$totalPoints'],
              ),
              style: TextStyleManager.style10Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: onMonthChanged == null ? null : () => onMonthChanged!(1),
          icon: Icon(Icons.chevron_right, color: AppColors.textPrimary, size: 22.sp),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final CheckInCalendarDayModel day;
  final bool isFuture;

  const _DayCell({required this.day, this.isFuture = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFuture)
            SizedBox(height: 26.r)
          else
            AppImage(
              day.checkedIn ? SvgIcons.awardGreenFire : SvgIcons.awardRedFire,
              width: 26.r,
              height: 26.r,
            ),
          SizedBox(height: 2.h),
          Text(
            '${day.dayOfMonth}',
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
