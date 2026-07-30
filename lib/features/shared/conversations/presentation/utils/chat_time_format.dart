import 'package:easy_localization/easy_localization.dart';

/// `h:mm ص/م` — the timestamp shown under a chat bubble.
String formatChatTime(DateTime time) {
  final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final String minute = time.minute.toString().padLeft(2, '0');
  final String meridiem =
      time.hour >= 12 ? 'shared_mock_pm'.tr() : 'shared_mock_am'.tr();
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
