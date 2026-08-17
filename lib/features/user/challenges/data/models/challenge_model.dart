/// What a challenge measures. There are exactly four and there will not be a
/// fifth — in particular there is no weight-loss metric.
enum ChallengeMetric {
  /// Steps, fed by walking.
  steps,

  /// **Kilometres**, fed by walking and running. Deltas are sent in metres; the
  /// backend converts, so nothing here needs converting again.
  distanceKm,

  /// kcal, fed by walking and running. Computed server-side from distance and
  /// the user's profile weight — the app never sends calories.
  calories,

  /// Millilitres, fed by hydration.
  waterMl;

  static ChallengeMetric? fromWire(String? value) => switch (value) {
        'steps' => ChallengeMetric.steps,
        'distance_km' => ChallengeMetric.distanceKm,
        'calories' => ChallengeMetric.calories,
        'water_ml' => ChallengeMetric.waterMl,
        _ => null,
      };
}

/// Where a challenge sits relative to *today*, which is about its dates and
/// says nothing about the user. An `ended` challenge with `isCompleted: false`
/// is the "you didn't make it" state.
enum ChallengeStatus {
  active,
  upcoming,
  ended;

  static ChallengeStatus? fromWire(String? value) => switch (value) {
        'active' => ChallengeStatus.active,
        'upcoming' => ChallengeStatus.upcoming,
        'ended' => ChallengeStatus.ended,
        _ => null,
      };
}

/// A challenge card, and — with [rules] filled in — the details sheet.
///
/// Created by the admin from the dashboard; the app only lists, joins and
/// leaves. Everything user-visible ([name], [description], [unit], [rules])
/// arrives already translated to the `lang` header, so none of it may be built
/// or mapped in the app.
class ChallengeModel {
  final String id;
  final String name;
  final String description;

  /// Null until the admin uploads artwork.
  final String? image;

  /// Null when the backend introduces a metric this build doesn't know about —
  /// the card still renders, it just can't pick a metric-specific icon.
  final ChallengeMetric? metric;

  /// Already translated. Never assembled from [metric] in the app.
  final String unit;

  final double goal;
  final DateTime? startDate;
  final DateTime? endDate;
  final ChallengeStatus? status;

  /// Display only — goes up and down as people join and leave.
  final int participantsCount;

  final bool isJoined;

  /// This user's progress, in [unit]. Zero when not joined.
  final double progress;

  /// Capped at 100 by the backend so a ring can never overshoot. For the raw
  /// figure use [progress] against [goal].
  final double progressPercentage;

  /// Once true, never false again — progress stops accruing afterwards.
  final bool isCompleted;

  final DateTime? completedAt;

  /// The **القواعد** tab, already translated. Only `GET /challenges/:id` fills
  /// this; it is empty on list cards, and may legitimately be empty there too.
  final List<String> rules;

  const ChallengeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.goal,
    required this.participantsCount,
    required this.isJoined,
    required this.progress,
    required this.progressPercentage,
    required this.isCompleted,
    this.image,
    this.metric,
    this.startDate,
    this.endDate,
    this.status,
    this.completedAt,
    this.rules = const [],
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      // `challengeId` on a sync response, `id` on the list and details ones.
      id: (json['id'] ?? json['challengeId']) as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
      metric: ChallengeMetric.fromWire(json['metric'] as String?),
      unit: json['unit'] as String? ?? '',
      goal: (json['goal'] as num?)?.toDouble() ?? 0,
      startDate: DateTime.tryParse(json['startDate'] as String? ?? ''),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? ''),
      status: ChallengeStatus.fromWire(json['status'] as String?),
      participantsCount: (json['participantsCount'] as num?)?.toInt() ?? 0,
      isJoined: json['isJoined'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      progressPercentage:
          (json['progressPercentage'] as num?)?.toDouble() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
      rules: (json['rules'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  /// This record with only the numbers a sync owns taken from [ledger].
  ///
  /// `POST /activity-sync` reports a *ledger* entry: `challengeId`, `name`,
  /// `metric`, `unit`, `goal` and this user's figures — and nothing else. It
  /// carries no `isJoined`, no dates, no `participantsCount` and no `status`,
  /// so parsing one through [ChallengeModel.fromJson] yields `isJoined: false`,
  /// null dates and zero participants.
  ///
  /// Swapping that in for the full record is what made a joined challenge jump
  /// out of the active section and into "suggested" — with blank dates — after
  /// every session stop. So the ledger's numbers are merged onto the record
  /// rather than replacing it.
  ChallengeModel withLedgerProgress(ChallengeModel ledger) {
    return ChallengeModel(
      id: id,
      name: name,
      description: description,
      image: image,
      metric: metric,
      unit: unit,
      goal: goal,
      startDate: startDate,
      endDate: endDate,
      status: status,
      participantsCount: participantsCount,
      isJoined: isJoined,
      rules: rules,
      // The four the sync is authoritative for.
      progress: ledger.progress,
      progressPercentage: ledger.progressPercentage,
      isCompleted: ledger.isCompleted,
      completedAt: ledger.completedAt,
    );
  }

  /// Ring fill, 0–1.
  double get progressFraction => (progressPercentage / 100).clamp(0.0, 1.0);

  /// "15000 خطوة" — the number with the unit the server already translated.
  String get goalLabel => '${_number(goal)} $unit'.trim();

  /// "6600 / 15000 خطوة".
  String get progressLabel => '${_number(progress)} / ${_number(goal)} $unit'.trim();

  String get startLabel => _day(startDate);
  String get endLabel => _day(endDate);

  /// Whole numbers lose their `.0`; a fractional goal (a distance one, say)
  /// keeps two decimals. Latin digits in both languages, matching how every
  /// other number in the app is written.
  static String _number(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  }

  /// `d/M/yyyy` in local time. The server sends these with a +03:00 offset, so
  /// converting is what puts the challenge on the day the user calls it.
  static String _day(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}

/// One page of `GET /challenges`. The paging fields sit beside `data`, not
/// inside it.
class ChallengesPageModel {
  final List<ChallengeModel> challenges;
  final int totalCount;
  final int page;
  final int totalPages;

  const ChallengesPageModel({
    required this.challenges,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  factory ChallengesPageModel.fromJson(Map<String, dynamic> json) {
    return ChallengesPageModel(
      challenges: (json['data'] as List<dynamic>?)
              ?.map((e) => ChallengeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  bool get hasMore => page < totalPages;
}
