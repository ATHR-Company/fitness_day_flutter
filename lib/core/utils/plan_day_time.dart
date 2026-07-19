import 'package:flutter/material.dart';

final RegExp _isoDatePrefix = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');

const List<int> _daysInMonthTable = [
  31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
];

bool _isLeapYear(int year) {
  return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}

int _daysInMonth(int year, int month) {
  if (month == 2 && _isLeapYear(year)) return 29;
  return _daysInMonthTable[month - 1];
}

/// Builds the ISO-8601 timestamp sent for a custom-plan item (meal, workout,
/// activity), assembled as plain text — no [DateTime] math, so there is no
/// local/UTC conversion or DST rollover to go wrong.
///
/// The date is forced from the assessment's [weekStart] plus ([dayNumber] - 1)
/// days — day 1 is always [weekStart]'s calendar date, day 2 the next day, and
/// so on — no matter what wall-clock [time] the user picks. [time]'s hour and
/// minute are written into the string exactly as picked.
///
/// Falls back to today (read once, no conversion) when [weekStart] is empty
/// or unparsable.
String buildPlanItemTime({
  required String weekStart,
  required int dayNumber,
  required TimeOfDay time,
}) {
  final match = _isoDatePrefix.firstMatch(weekStart);

  int year;
  int month;
  int day;
  if (match != null) {
    year = int.parse(match.group(1)!);
    month = int.parse(match.group(2)!);
    day = int.parse(match.group(3)!);
  } else {
    final now = DateTime.now();
    year = now.year;
    month = now.month;
    day = now.day;
  }

  for (var i = 0; i < dayNumber - 1; i++) {
    day += 1;
    if (day > _daysInMonth(year, month)) {
      day = 1;
      month += 1;
      if (month > 12) {
        month = 1;
        year += 1;
      }
    }
  }

  final y = year.toString().padLeft(4, '0');
  final m = month.toString().padLeft(2, '0');
  final d = day.toString().padLeft(2, '0');
  final hh = time.hour.toString().padLeft(2, '0');
  final mm = time.minute.toString().padLeft(2, '0');

  return '$y-$m-${d}T$hh:$mm:00.000Z';
}
