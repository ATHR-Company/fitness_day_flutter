/// State of a single card in the 7-day cycle, exactly as the backend names it.
///
/// [unknown] exists only so a value the backend adds later cannot crash the
/// screen; nothing renders a fourth state — an unknown day is drawn locked.
enum CheckInDayState { claimed, available, locked, unknown }

CheckInDayState _parseDayState(dynamic raw) {
  switch (raw) {
    case 'CLAIMED':
      return CheckInDayState.claimed;
    case 'AVAILABLE':
      return CheckInDayState.available;
    case 'LOCKED':
      return CheckInDayState.locked;
    default:
      return CheckInDayState.unknown;
  }
}

class CheckInDayModel {
  final int dayNumber;

  /// Points this day pays. Configured from the dashboard and changes without an
  /// app release — never hardcode the ladder.
  final int points;
  final CheckInDayState state;

  const CheckInDayModel({
    required this.dayNumber,
    required this.points,
    required this.state,
  });

  factory CheckInDayModel.fromJson(Map<String, dynamic> json) {
    return CheckInDayModel(
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      state: _parseDayState(json['state']),
    );
  }
}

/// Response of both `GET /daily-check-in/status` and
/// `POST /daily-check-in/claim` — the claim response is the same document plus
/// [pointsAwarded], so the screen re-renders wholesale from whichever it got
/// last instead of patching state locally.
class DailyCheckInStatusModel {
  final int pointsBalance;
  final int currentStreak;
  final int longestStreak;
  final bool canClaimToday;

  /// Which of the seven cards is today's, `1..7`.
  final int todayCycleDay;

  /// The "+N" on the claim button, so the UI never searches [days] for it.
  final int todayPoints;
  final String? lastCheckInAt;
  final List<CheckInDayModel> days;

  /// Only present on a claim response — drives the "+N" animation.
  final int? pointsAwarded;

  const DailyCheckInStatusModel({
    required this.pointsBalance,
    required this.currentStreak,
    required this.longestStreak,
    required this.canClaimToday,
    required this.todayCycleDay,
    required this.todayPoints,
    required this.days,
    this.lastCheckInAt,
    this.pointsAwarded,
  });

  factory DailyCheckInStatusModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawDays = json['days'];
    return DailyCheckInStatusModel(
      pointsBalance: (json['pointsBalance'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      canClaimToday: json['canClaimToday'] as bool? ?? false,
      todayCycleDay: (json['todayCycleDay'] as num?)?.toInt() ?? 1,
      todayPoints: (json['todayPoints'] as num?)?.toInt() ?? 0,
      lastCheckInAt: json['lastCheckInAt'] as String?,
      pointsAwarded: (json['pointsAwarded'] as num?)?.toInt(),
      days: rawDays is List
          ? rawDays
              .whereType<Map<String, dynamic>>()
              .map(CheckInDayModel.fromJson)
              .toList()
          : const <CheckInDayModel>[],
    );
  }
}
