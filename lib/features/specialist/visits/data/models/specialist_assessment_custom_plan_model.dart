import 'package:fitness_day/features/specialist/visits/data/models/assessment_current_state.dart';

class SpecialistAssessmentCustomPlanResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistAssessmentCustomPlanModel? data;

  SpecialistAssessmentCustomPlanResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistAssessmentCustomPlanResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistAssessmentCustomPlanResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistAssessmentCustomPlanModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistAssessmentCustomPlanModel {
  final int dayNumber;
  final List<SpecialistMealModel> meals;
  final List<SpecialistWorkoutModel> workoutPlan;
  final List<SpecialistActivityModel> activities;
  final AssessmentCurrentState? currentState;
  final bool canFinishAssessment;

  SpecialistAssessmentCustomPlanModel({
    required this.dayNumber,
    required this.meals,
    required this.workoutPlan,
    required this.activities,
    this.currentState,
    this.canFinishAssessment = false,
  });

  factory SpecialistAssessmentCustomPlanModel.fromJson(Map<String, dynamic> json) {
    final stateStr = json['currentState'] as String?;
    return SpecialistAssessmentCustomPlanModel(
      dayNumber: json['dayNumber'] as int? ?? 1,
      meals: (json['meals'] as List<dynamic>?)
              ?.map((e) => SpecialistMealModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      workoutPlan: (json['workoutPlan'] as List<dynamic>?)
              ?.map((e) => SpecialistWorkoutModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => SpecialistActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentState: AssessmentCurrentState.fromJson(stateStr),
      canFinishAssessment: (json['canFinishAssessment'] as bool? ?? false) ||
          stateStr == 'READY_TO_FINISH' ||
          stateStr == 'COMPLETED',
    );
  }
}

class SpecialistMealModel {
  final String mealId;
  final String name;
  final String categoryName;
  final String time;
  final String image;
  final double calories;
  final bool isCompleted;

  SpecialistMealModel({
    required this.mealId,
    required this.name,
    required this.categoryName,
    required this.time,
    required this.image,
    required this.calories,
    required this.isCompleted,
  });

  factory SpecialistMealModel.fromJson(Map<String, dynamic> json) {
    return SpecialistMealModel(
      mealId: json['mealId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      time: json['time'] as String? ?? '',
      image: json['image'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class SpecialistWorkoutModel {
  final String workoutItemId;
  final String name;
  final String description;
  final String photo;
  final String time;
  final int totalSets;
  final int completedSets;
  final bool isCompleted;

  SpecialistWorkoutModel({
    required this.workoutItemId,
    required this.name,
    required this.description,
    required this.photo,
    required this.time,
    required this.totalSets,
    required this.completedSets,
    required this.isCompleted,
  });

  factory SpecialistWorkoutModel.fromJson(Map<String, dynamic> json) {
    return SpecialistWorkoutModel(
      workoutItemId: json['workoutItemId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photo: json['photo'] as String? ?? '',
      time: json['time'] as String? ?? '',
      totalSets: json['totalSets'] as int? ?? 0,
      completedSets: json['completedSets'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class SpecialistActivityModel {
  final String activityItemId;
  final String activityId;
  final String activityType;
  final String name;
  final String description;
  final String image;
  final String unit;
  final double goal;
  final double currentProgress;
  final bool isCompleted;

  SpecialistActivityModel({
    required this.activityItemId,
    required this.activityId,
    required this.activityType,
    required this.name,
    required this.description,
    required this.image,
    required this.unit,
    required this.goal,
    required this.currentProgress,
    required this.isCompleted,
  });

  factory SpecialistActivityModel.fromJson(Map<String, dynamic> json) {
    return SpecialistActivityModel(
      activityItemId: json['activityItemId'] as String? ?? '',
      activityId: json['activityId'] as String? ?? '',
      activityType: json['activityType'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      goal: (json['goal'] as num?)?.toDouble() ?? 0.0,
      currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
