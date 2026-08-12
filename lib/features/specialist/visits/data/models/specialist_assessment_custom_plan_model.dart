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

/// One ingredient of a planned meal, at the weight the specialist saved.
///
/// Not the template's default weight — the meal template says 150g of pasta,
/// this says the 156g that was actually prescribed for this client.
class SpecialistMealIngredientModel {
  final String ingredientId;
  final String name;
  final double weight;
  final String unit;

  SpecialistMealIngredientModel({
    required this.ingredientId,
    required this.name,
    required this.weight,
    required this.unit,
  });

  factory SpecialistMealIngredientModel.fromJson(Map<String, dynamic> json) {
    return SpecialistMealIngredientModel(
      ingredientId: json['ingredientId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
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

  /// Ids of the lookups this meal was built from. The edit screen selects by
  /// these rather than matching the lookup lists by name — two categories can
  /// share a display name, and a rename on the backend used to silently land
  /// the specialist on whichever entry happened to be first.
  final String mealCategoryId;
  final String mealTemplateId;

  /// What was actually prescribed, so opening the edit screen shows the saved
  /// weights instead of resetting them to the template's defaults.
  final List<SpecialistMealIngredientModel> ingredients;

  SpecialistMealModel({
    required this.mealId,
    required this.name,
    required this.categoryName,
    required this.time,
    required this.image,
    required this.calories,
    required this.isCompleted,
    this.mealCategoryId = '',
    this.mealTemplateId = '',
    this.ingredients = const [],
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
      mealCategoryId: json['mealCategoryId'] as String? ?? '',
      mealTemplateId: json['mealTemplateId'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => SpecialistMealIngredientModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
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

  /// The lookup this item was built from, so the edit screen can select it by
  /// id instead of matching the exercise list by name.
  final String exerciseId;

  /// What was prescribed. [totalSets] is the same number as [sets]; both are
  /// kept because the card reads the progress pair (`completedSets/totalSets`)
  /// while the edit form reads the prescription.
  final int sets;
  final int reps;
  final int restDuration;

  SpecialistWorkoutModel({
    required this.workoutItemId,
    required this.name,
    required this.description,
    required this.photo,
    required this.time,
    required this.totalSets,
    required this.completedSets,
    required this.isCompleted,
    this.exerciseId = '',
    this.sets = 0,
    this.reps = 0,
    this.restDuration = 0,
  });

  factory SpecialistWorkoutModel.fromJson(Map<String, dynamic> json) {
    final int totalSets = json['totalSets'] as int? ?? 0;
    return SpecialistWorkoutModel(
      workoutItemId: json['workoutItemId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photo: json['photo'] as String? ?? '',
      time: json['time'] as String? ?? '',
      totalSets: totalSets,
      completedSets: json['completedSets'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      exerciseId: json['exerciseId'] as String? ?? '',
      sets: json['sets'] as int? ?? totalSets,
      reps: json['reps'] as int? ?? 0,
      restDuration: json['restDuration'] as int? ?? 0,
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

  /// Not shown anywhere — an activity runs across the whole day, so the edit
  /// screen doesn't ask for a time. It is carried so a PATCH can send back
  /// whatever was stored instead of overwriting it.
  final String time;

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
    this.time = '',
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
      time: json['time'] as String? ?? '',
    );
  }
}
