class ActivityDetailsResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final ActivityDetailsData data;

  const ActivityDetailsResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ActivityDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return ActivityDetailsResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: ActivityDetailsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ActivityDetailsData {
  final String assessmentId;
  final int dayNumber;
  final String activityId;
  final String activityType;
  final String name;
  final String description;
  final String unit;
  final double goal;
  final double currentProgress;
  final double progressPercentage;
  final bool isCompleted;
  final String? time;
  final String? completedAt;
  final String? addedAt;
  final int? durationMinutes;
  final double? caloriesBurned;
  final double? distance;

  const ActivityDetailsData({
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
    required this.activityType,
    required this.name,
    required this.description,
    required this.unit,
    required this.goal,
    required this.currentProgress,
    required this.progressPercentage,
    required this.isCompleted,
    this.time,
    this.completedAt,
    this.addedAt,
    this.durationMinutes,
    this.caloriesBurned,
    this.distance,
  });

  factory ActivityDetailsData.fromJson(Map<String, dynamic> json) {
    return ActivityDetailsData(
      assessmentId: json['assessmentId'] as String? ?? '',
      dayNumber: json['dayNumber'] as int? ?? 1,
      activityId: json['activityId'] as String? ?? '',
      activityType: json['activityType'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      goal: (json['goal'] as num?)?.toDouble() ?? 0.0,
      currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? 0.0,
      progressPercentage:
          (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      time: json['time'] as String?,
      completedAt: json['completedAt'] as String?,
      addedAt: json['addedAt'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}
