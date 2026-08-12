/// A badge. Unlocked automatically on sync — there is nothing to claim and no
/// endpoint to call to earn one.
///
/// [name], [description] and [image] are dashboard-editable and must never be
/// hardcoded in the app. [code] is the stable key; use it only to pick a local
/// fallback asset, and expect [image] to be null until artwork is uploaded.
class AchievementModel {
  final String id;

  /// Stable identifier: `hydration_hero`, `steps_king`, `consistency`,
  /// `month_champion`, `first_challenge`.
  final String code;

  final String name;
  final String description;
  final String? image;

  /// False for badges the user has yet to earn — the wall lists those too, so
  /// there is something to aim for. Render them greyed out.
  final bool isUnlocked;

  final DateTime? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.isUnlocked,
    this.image,
    this.unlockedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: DateTime.tryParse(json['unlockedAt'] as String? ?? ''),
    );
  }
}

/// `GET /achievements` — the whole wall, locked and unlocked.
class AchievementsWallModel {
  final int unlockedCount;
  final int totalCount;
  final List<AchievementModel> achievements;

  const AchievementsWallModel({
    required this.unlockedCount,
    required this.totalCount,
    required this.achievements,
  });

  factory AchievementsWallModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return AchievementsWallModel(
      unlockedCount: (data['unlockedCount'] as num?)?.toInt() ?? 0,
      totalCount: (data['totalCount'] as num?)?.toInt() ?? 0,
      achievements: (data['achievements'] as List<dynamic>?)
              ?.map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

/// One chip in the week strip.
class AchievementDayModel {
  final String dayKey;

  /// How many badges were unlocked that day — drives the dot on the chip.
  final int count;

  const AchievementDayModel({required this.dayKey, required this.count});

  factory AchievementDayModel.fromJson(Map<String, dynamic> json) {
    return AchievementDayModel(
      dayKey: json['dayKey'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// `GET /achievements/daily` — the day strip and the selected day's badges.
class AchievementsDailyModel {
  final String date;

  /// Seven days **ending on** [date], oldest first.
  final List<AchievementDayModel> week;

  /// Only what was unlocked on [date]. Empty is the "no achievements yet"
  /// state, not an error.
  final List<AchievementModel> achievements;

  const AchievementsDailyModel({
    required this.date,
    required this.week,
    required this.achievements,
  });

  factory AchievementsDailyModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return AchievementsDailyModel(
      date: data['date'] as String? ?? '',
      week: (data['week'] as List<dynamic>?)
              ?.map((e) =>
                  AchievementDayModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      achievements: (data['achievements'] as List<dynamic>?)
              ?.map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
