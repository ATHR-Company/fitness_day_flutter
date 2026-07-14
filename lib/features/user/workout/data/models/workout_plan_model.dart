class WorkoutItemModel {
  final String id;
  final String name;
  final String description;
  final String photo;
  final String time;
  final int totalSets;
  final int completedSets;
  final bool isCompleted;

  const WorkoutItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.photo,
    required this.time,
    required this.totalSets,
    required this.completedSets,
    required this.isCompleted,
  });

  factory WorkoutItemModel.fromJson(Map<String, dynamic> json) {
    return WorkoutItemModel(
      id: json['workoutItemId'] as String? ?? json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photo: json['photo'] as String? ?? '',
      time: json['time'] as String? ?? '',
      totalSets: json['totalSets'] as int? ?? 0,
      completedSets: json['completedSets'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo': photo,
      'time': time,
      'totalSets': totalSets,
      'completedSets': completedSets,
      'isCompleted': isCompleted,
    };
  }
}

class WorkoutPlanData {
  final String assessmentId;
  final int dayNumber;
  final List<WorkoutItemModel> workouts;

  const WorkoutPlanData({
    required this.assessmentId,
    required this.dayNumber,
    required this.workouts,
  });

  factory WorkoutPlanData.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanData(
      assessmentId: json['assessmentId'] as String? ?? '',
      dayNumber: json['dayNumber'] as int? ?? 1,
      workouts: (json['workouts'] as List<dynamic>?)
              ?.map((e) => WorkoutItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assessmentId': assessmentId,
      'dayNumber': dayNumber,
      'workouts': workouts.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkoutPlanResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final WorkoutPlanData? data;

  const WorkoutPlanResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory WorkoutPlanResponseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? WorkoutPlanData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
      'data': data?.toJson(),
    };
  }
}
