/// Payload for `POST /user-activities/running/sync`.
///
/// Like walking, progress fields are **deltas** applied server-side with
/// `$inc`, and [syncId] makes a retry idempotent.
class RunningSyncRequestModel {
  final String assessmentId;
  final int dayNumber;
  final String activityId;

  /// Unique `_id` of the item inside the plan day — [activityId] alone is the
  /// catalog reference and is shared by every running item in the day.
  final String activityItemId;

  /// Distance delta in **metres** — the server contract is not kilometres.
  final double deltaDistance;

  final int durationSeconds;

  /// Only a sync carrying this completes the running activity server-side.
  final bool isFinal;

  final String syncId;

  const RunningSyncRequestModel({
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
    required this.activityItemId,
    required this.deltaDistance,
    required this.durationSeconds,
    required this.isFinal,
    required this.syncId,
  });

  Map<String, dynamic> toJson() => {
        'assessmentId': assessmentId,
        'dayNumber': dayNumber,
        'activityId': activityId,
        'activityItemId': activityItemId,
        'deltaDistance': deltaDistance,
        'durationSeconds': durationSeconds,
        'isFinal': isFinal,
        'syncId': syncId,
      };
}

class RunningSyncResponseModel {
  final String? message;

  /// Calories are computed by the backend from the distance we post, so this is
  /// the only source for them during a run.
  final double? caloriesBurned;

  const RunningSyncResponseModel({this.message, this.caloriesBurned});

  factory RunningSyncResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];
    final dynamic calories = data is Map ? data['caloriesBurned'] : null;
    final dynamic message = json['message'];
    return RunningSyncResponseModel(
      message: message is String ? message : null,
      caloriesBurned: calories is num ? calories.toDouble() : null,
    );
  }
}
