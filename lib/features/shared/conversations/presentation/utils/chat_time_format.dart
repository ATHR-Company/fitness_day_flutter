import 'package:easy_localization/easy_localization.dart';

/// `h:mm ص/م` — the timestamp shown under a chat bubble.
///
/// Converts to the device's timezone first. `.hour` on a UTC DateTime is the
/// UTC hour, and the API sends every timestamp as UTC, so without this the
/// whole chat reads three hours behind in Riyadh. Already-local values are
/// unaffected — [DateTime.toLocal] is a no-op on them.
String formatChatTime(DateTime time) {
  final local = time.toLocal();
  final int hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final String minute = local.minute.toString().padLeft(2, '0');
  final String meridiem =
      local.hour >= 12 ? 'shared_mock_pm'.tr() : 'shared_mock_am'.tr();
  return '$hour:$minute $meridiem';
}

/// `mm:ss` — the elapsed length of a voice note.
String formatChatDuration(Duration duration) {
  final String minutes =
      duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final String seconds =
      duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
