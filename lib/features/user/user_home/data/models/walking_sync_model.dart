/// Payload for `POST /user-activities/walking/sync`.
///
/// Every field the server matches on is named explicitly — nothing is inferred
/// from the session. Progress fields are **deltas**: the server applies them
/// with `$inc`, so a cumulative total would compound.
class WalkingSyncRequestModel {
  final String assessmentId;
  final int dayNumber;
  final String activityId;

  /// Unique `_id` of the item inside the plan day — [activityId] alone is the
  /// catalog reference and is shared by every walking item in the day.
  final String activityItemId;

  final int deltaSteps;

  /// Distance delta in **metres** — the server contract is not kilometres.
  final double deltaDistance;

  final int durationSeconds;

  /// Idempotency key. A retried attempt reuses it so a request that reached the
  /// server but lost its response is recognised as a replay, not applied twice.
  final String syncId;

  const WalkingSyncRequestModel({
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
    required this.activityItemId,
    required this.deltaSteps,
    required this.deltaDistance,
    required this.durationSeconds,
    required this.syncId,
  });

  Map<String, dynamic> toJson() => {
        'assessmentId': assessmentId,
        'dayNumber': dayNumber,
        'activityId': activityId,
        'activityItemId': activityItemId,
        'deltaSteps': deltaSteps,
        'deltaDistance': deltaDistance,
        'durationSeconds': durationSeconds,
        'syncId': syncId,
      };
}

class WalkingSyncResponseModel {
  final String? message;

  /// Calories the server credited after applying the delta, when it reports any.
  final double? caloriesBurned;

  const WalkingSyncResponseModel({this.message, this.caloriesBurned});

  factory WalkingSyncResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];
    final dynamic calories = data is Map ? data['caloriesBurned'] : null;
    final dynamic message = json['message'];
    return WalkingSyncResponseModel(
      message: message is String ? message : null,
      caloriesBurned: calories is num ? calories.toDouble() : null,
    );
  }
}
