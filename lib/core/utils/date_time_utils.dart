import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Wall-clock time of a custom-plan item — always Latin digits and English
/// AM/PM, whatever the app language is.
///
/// Pinned to `en` on purpose: [TimePickerBottomSheet] renders its spinner under
/// a forced `en_US` Localizations override, so formatting the result with the
/// app locale meant the specialist picked `08:30 PM` and the field underneath
/// then read it back as `٠٨:٣٠ م`.
String formatPlanClock(DateTime time) =>
    DateFormat('hh:mm a', 'en').format(time);

/// Same, for a time that arrives as an ISO string from the API.
///
/// Returns the input untouched when it can't be parsed — the server has sent
/// plain `"08:00"` alongside full timestamps, and showing that is better than
/// showing nothing.
String formatPlanClockIso(String isoTime) {
  if (isoTime.isEmpty) return '';
  final parsed = DateTime.tryParse(isoTime);
  if (parsed == null) return isoTime;
  return formatPlanClock(parsed.isUtc ? parsed.toLocal() : parsed);
}

String formatVisitDate(String isoDate, BuildContext context) {
  if (isoDate.isEmpty) return '';
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return isoDate;
  return DateFormat('yyyy-MM-dd hh:mm a', context.locale.languageCode)
      .format(parsed.toLocal());
}

String formatVisitTimeRemaining(String isoDate, BuildContext context) {
  if (isoDate.isEmpty) return '';

  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return '';

  final now = DateTime.now();
  final target = parsed.toLocal();
  final diff = target.difference(now);
  if (diff.isNegative) return '';

  if (diff.inMinutes < 1) {
    return 'visits.in_less_than_a_minute'.tr();
  }

  if (diff.inMinutes < 60) {
    return 'visits.in_minutes'.tr(args: [diff.inMinutes.toString()]);
  }

  if (diff.inHours < 24) {
    return 'visits.in_hours'.tr(args: [diff.inHours.toString()]);
  }

  return 'visits.in_days'.tr(args: [diff.inDays.toString()]);
}
