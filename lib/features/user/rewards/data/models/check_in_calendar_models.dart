/// One day of the monthly grid. Every day of the month is always present, so
/// the UI never has to fill gaps.
class CheckInCalendarDayModel {
  /// `YYYY-MM-DD`, kept as the raw string on purpose: parsing it into a local
  /// `DateTime` shifts the last day of the month for users behind UTC.
  final String date;
  final int dayOfMonth;
  final bool checkedIn;
  final int points;

  const CheckInCalendarDayModel({
    required this.date,
    required this.dayOfMonth,
    required this.checkedIn,
    required this.points,
  });

  factory CheckInCalendarDayModel.fromJson(Map<String, dynamic> json) {
    return CheckInCalendarDayModel(
      date: json['date'] as String? ?? '',
      dayOfMonth: (json['dayOfMonth'] as num?)?.toInt() ?? 0,
      checkedIn: json['checkedIn'] as bool? ?? false,
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }
}

class CheckInCalendarModel {
  final int year;

  /// 1-based: 1 = January, 12 = December.
  final int month;
  final int checkedInDays;
  final int totalPoints;
  final List<CheckInCalendarDayModel> days;

  const CheckInCalendarModel({
    required this.year,
    required this.month,
    required this.checkedInDays,
    required this.totalPoints,
    required this.days,
  });

  factory CheckInCalendarModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawDays = json['days'];
    return CheckInCalendarModel(
      year: (json['year'] as num?)?.toInt() ?? 0,
      month: (json['month'] as num?)?.toInt() ?? 1,
      checkedInDays: (json['checkedInDays'] as num?)?.toInt() ?? 0,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      days: rawDays is List
          ? rawDays
              .whereType<Map<String, dynamic>>()
              .map(CheckInCalendarDayModel.fromJson)
              .toList()
          : const <CheckInCalendarDayModel>[],
    );
  }
}
