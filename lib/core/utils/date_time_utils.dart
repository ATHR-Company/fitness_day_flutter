import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
