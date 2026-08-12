import 'package:fitness_day/features/user/challenges/data/models/achievement_model.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';

/// Which activity produced a delta. The backend reads a different subset of
/// fields per source and ignores the rest, so all three cubits can send the
/// same payload shape.
enum ActivitySource {
  walking,
  running,
  hydration;

  String get wireValue => name;
}

/// Payload for `POST /activity-sync` — the challenges/achievements ledger.
///
/// Deltas, never totals: the backend adds what is sent to what it holds. The
/// plan's own sync endpoints are fed the *same* numbers separately; neither
/// total is derived from the other.
class ActivitySyncRequestModel {
  final ActivitySource source;

  /// Walking only.
  final int? deltaSteps;

  /// Walking and running. **Metres** — the response reports kilometres, and a
  /// distance challenge's goal is in kilometres. The backend converts; the app
  /// must not convert twice.
  final double? deltaDistanceMeters;

  /// Walking and running.
  final int? durationSeconds;

  /// Hydration only, and the only field allowed to be negative — removing a
  /// glass logged by mistake sends a negative value. Totals are floored at zero
  /// server-side.
  final int? deltaWaterMl;

  /// Idempotency key, UUID v4. A retry reuses it so a request that reached the
  /// server but lost its response is recognised as a replay instead of being
  /// counted twice.
  final String syncId;

  const ActivitySyncRequestModel({
    required this.source,
    required this.syncId,
    this.deltaSteps,
    this.deltaDistanceMeters,
    this.durationSeconds,
    this.deltaWaterMl,
  });

  /// Only the fields this [source] is read for. Sending the others would be
  /// harmless — the backend drops them — but keeping the payload honest makes
  /// a wrong-field bug visible in the request log instead of silent.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'source': source.wireValue,
      'syncId': syncId,
    };

    switch (source) {
      case ActivitySource.walking:
        json['deltaSteps'] = deltaSteps ?? 0;
        json['deltaDistanceMeters'] = deltaDistanceMeters ?? 0;
        json['durationSeconds'] = durationSeconds ?? 0;
      case ActivitySource.running:
        json['deltaDistanceMeters'] = deltaDistanceMeters ?? 0;
        json['durationSeconds'] = durationSeconds ?? 0;
      case ActivitySource.hydration:
        json['deltaWaterMl'] = deltaWaterMl ?? 0;
    }

    return json;
  }
}

/// A day's running totals, as `GET /activity-sync/daily` and every sync report
/// them.
class ActivityTotalsModel {
  /// The day this belongs to, bucketed in Asia/Riyadh — authoritative. A local
  /// day bucket must be keyed off this string rather than computed from the
  /// device clock, which is neither Riyadh nor necessarily correct.
  final String dayKey;

  final int steps;

  /// Kilometres. Note the asymmetry with the request, which is in metres.
  final double distanceKm;

  final double calories;
  final int waterMl;
  final double activeMinutes;

  const ActivityTotalsModel({
    required this.dayKey,
    required this.steps,
    required this.distanceKm,
    required this.calories,
    required this.waterMl,
    required this.activeMinutes,
  });

  factory ActivityTotalsModel.fromJson(Map<String, dynamic> json) {
    return ActivityTotalsModel(
      dayKey: json['dayKey'] as String? ?? '',
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      waterMl: (json['waterMl'] as num?)?.toInt() ?? 0,
      activeMinutes: (json['activeMinutes'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// What a sync gives back: the day after the delta, every live challenge, and
/// whatever this particular sync unlocked.
class ActivitySyncResultModel {
  /// True when the [ActivitySyncRequestModel.syncId] had already been seen and
  /// nothing was applied. Everything else in the response is still current, so
  /// render it normally — [newAchievements] is always empty here.
  final bool replayed;

  final ActivityTotalsModel totals;

  /// **Every** challenge the user has joined whose window covers now, not only
  /// the ones this sync moved. Redraw the list from this wholesale.
  final List<ChallengeModel> challenges;

  /// Unlocked *by this sync only*. Non-empty means: celebrate. The backend has
  /// already done the diffing, so the app never has to.
  final List<AchievementModel> newAchievements;

  /// How many challenges crossed their goal on this sync.
  final int completedChallenges;

  const ActivitySyncResultModel({
    required this.replayed,
    required this.totals,
    required this.challenges,
    required this.newAchievements,
    required this.completedChallenges,
  });

  factory ActivitySyncResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final totals = data['totals'] as Map<String, dynamic>? ?? const {};

    return ActivitySyncResultModel(
      replayed: data['replayed'] as bool? ?? false,
      // `dayKey` sits beside `totals`, not inside it.
      totals: ActivityTotalsModel.fromJson({
        ...totals,
        'dayKey': data['dayKey'],
      }),
      challenges: (data['challenges'] as List<dynamic>?)
              ?.map((e) => ChallengeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      newAchievements: (data['newAchievements'] as List<dynamic>?)
              ?.map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      completedChallenges: (data['completedChallenges'] as num?)?.toInt() ?? 0,
    );
  }
}
