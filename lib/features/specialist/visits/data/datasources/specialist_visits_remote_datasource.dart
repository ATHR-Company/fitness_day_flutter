import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_history_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_visit_data_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_start_visit_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_finish_visit_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_update_goal_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_update_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_plan_lookups_model.dart';
import 'package:fitness_day/features/user/visits/data/models/meal_details_model.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_details_model.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';


abstract class SpecialistVisitsRemoteDataSource {
  Future<SpecialistAssessmentHistoryResponseModel> getAssessmentHistory({
    required String type,
    required int page,
    required int limit,
    String? search,
  });

  Future<SpecialistAssessmentVisitDataResponseModel> getVisitData({
    required String assessmentId,
  });

  Future<SpecialistAssessmentHealthReportResponseModel> getHealthReport({
    required String assessmentId,
  });

  Future<SpecialistAssessmentCustomPlanResponseModel> getCustomPlan({
    required String assessmentId,
    required int dayNumber,
  });

  Future<SpecialistStartVisitResponseModel> startVisit({
    required String assessmentId,
  });

  Future<SpecialistFinishVisitResponseModel> finishVisit({
    required String assessmentId,
  });

  Future<SpecialistUpdateGoalResponseModel> updateGoal({
    required String assessmentId,
    required String goal,
  });

  Future<SpecialistUpdateHealthReportResponseModel> updateHealthReport({
    required String assessmentId,
    required double weight,
    required double height,
    required double bmi,
    required double bmr,
    required double fatWeight,
    required double fatPercentage,
    required double muscleWeight,
    required double musclePercentage,
    required double protein,
  });

  Future<SpecialistAssessmentCustomPlanResponseModel> updateCustomPlan({
    required String assessmentId,
    required int dayNumber,
    required Map<String, dynamic> planData,
  });

  Future<List<SpecialistMealCategoryModel>> getMealCategories();

  Future<List<SpecialistMealTemplateModel>> getMealTemplates({
    required String categoryId,
  });

  Future<List<SpecialistActivityLookupModel>> getActivities();

  Future<List<SpecialistExerciseLookupModel>> getExercises();

  Future<SpecialistAssessmentCustomPlanResponseModel> addMeal({
    required String assessmentId,
    required int dayNumber,
    required String mealCategoryId,
    required String mealTemplateId,
    required String time,
    required List<Map<String, dynamic>> ingredientWeights,
  });

  Future<SpecialistAssessmentCustomPlanResponseModel> addWorkout({
    required String assessmentId,
    required int dayNumber,
    required String exerciseId,
    required int sets,
    required int reps,
    required int restDuration,
    required String time,
  });

  Future<SpecialistAssessmentCustomPlanResponseModel> addActivity({
    required String assessmentId,
    required int dayNumber,
    required String activityId,
    required int goal,
    required String time,
  });

  Future<SpecialistAssessmentCustomPlanResponseModel> updateMeal({
    required String assessmentId,
    required int dayNumber,
    required String mealId,
    required String mealCategoryId,
    required String mealTemplateId,
    required String time,
    required List<Map<String, dynamic>> ingredientWeights,
  });

  Future<SpecialistAssessmentCustomPlanResponseModel> updateWorkout({
    required String assessmentId,
    required int dayNumber,
    required String workoutItemId,
    required String exerciseId,
    required int sets,
    required int reps,
    required int restDuration,
    required String time,
  });

  Future<SpecialistAssessmentCustomPlanResponseModel> updateActivity({
    required String assessmentId,
    required int dayNumber,
    required String activityItemId,
    required String activityId,
    required int goal,
    required String time,
  });

  Future<MealDetailsResponseModel> getMealDetails({
    required String assessmentId,
    required int dayNumber,
    required String mealId,
  });

  Future<WorkoutDetailsResponseModel> getWorkoutDetails({
    required String assessmentId,
    required int dayNumber,
    required String workoutItemId,
  });

  Future<ActivityDetailsResponseModel> getActivityDetails({
    required String assessmentId,
    required int dayNumber,
    required String activityItemId,
  });
}

class SpecialistVisitsRemoteDataSourceImpl implements SpecialistVisitsRemoteDataSource {
  final ApiService _apiService;

  SpecialistVisitsRemoteDataSourceImpl(this._apiService);

  @override
  Future<SpecialistAssessmentHistoryResponseModel> getAssessmentHistory({
    required String type,
    required int page,
    required int limit,
    String? search,
  }) async {
    final queryParams = {
      'type': type,
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final response = await _apiService.get(
      ApiEndpoints.specialistAssessmentHistory,
      queryParameters: queryParams,
    );
    return SpecialistAssessmentHistoryResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentVisitDataResponseModel> getVisitData({
    required String assessmentId,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistAssessmentDetails(assessmentId),
      queryParameters: {
        'type': 'VISIT_DATA',
      },
    );
    return SpecialistAssessmentVisitDataResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentHealthReportResponseModel> getHealthReport({
    required String assessmentId,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistAssessmentDetails(assessmentId),
      queryParameters: {
        'type': 'HEALTH_REPORT',
      },
    );
    return SpecialistAssessmentHealthReportResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentCustomPlanResponseModel> getCustomPlan({
    required String assessmentId,
    required int dayNumber,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistAssessmentDetails(assessmentId),
      queryParameters: {
        'type': 'CUSTOM_PLAN',
        'dayNumber': dayNumber,
      },
    );
    return SpecialistAssessmentCustomPlanResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistStartVisitResponseModel> startVisit({
    required String assessmentId,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.startSpecialistAssessment(assessmentId),
    );
    return SpecialistStartVisitResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistFinishVisitResponseModel> finishVisit({
    required String assessmentId,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.finishSpecialistAssessment(assessmentId),
    );
    return SpecialistFinishVisitResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistUpdateGoalResponseModel> updateGoal({
    required String assessmentId,
    required String goal,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.updateSpecialistAssessmentGoal(assessmentId),
      data: {
        'goal': goal,
      },
    );
    return SpecialistUpdateGoalResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistUpdateHealthReportResponseModel> updateHealthReport({
    required String assessmentId,
    required double weight,
    required double height,
    required double bmi,
    required double bmr,
    required double fatWeight,
    required double fatPercentage,
    required double muscleWeight,
    required double musclePercentage,
    required double protein,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.updateSpecialistAssessmentHealthReport(assessmentId),
      data: {
        'weight': weight,
        'height': height,
        'bmi': bmi,
        'bmr': bmr,
        'fatWeight': fatWeight,
        'fatPercentage': fatPercentage,
        'muscleWeight': muscleWeight,
        'musclePercentage': musclePercentage,
        'protein': protein,
      },
    );
    return SpecialistUpdateHealthReportResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentCustomPlanResponseModel> updateCustomPlan({
    required String assessmentId,
    required int dayNumber,
    required Map<String, dynamic> planData,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.updateSpecialistAssessmentPlan(assessmentId, dayNumber),
      data: planData,
    );
    return SpecialistAssessmentCustomPlanResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<SpecialistMealCategoryModel>> getMealCategories() async {
    final response = await _apiService.get(ApiEndpoints.specialistMealCategories);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => SpecialistMealCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SpecialistMealTemplateModel>> getMealTemplates({
    required String categoryId,
  }) async {
    final response = await _apiService.get(ApiEndpoints.specialistMealTemplates(categoryId));
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => SpecialistMealTemplateModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SpecialistActivityLookupModel>> getActivities() async {
    final response = await _apiService.get(ApiEndpoints.specialistActivities);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => SpecialistActivityLookupModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SpecialistExerciseLookupModel>> getExercises() async {
    final response = await _apiService.get(ApiEndpoints.specialistExercises);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => SpecialistExerciseLookupModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<SpecialistAssessmentCustomPlanResponseModel> addMeal({
    required String assessmentId,
    required int dayNumber,
    required String mealCategoryId,
    required String mealTemplateId,
    required String time,
    required List<Map<String, dynamic>> ingredientWeights,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.addSpecialistDayMeal(assessmentId, dayNumber),
      data: {
        'mealCategoryId': mealCategoryId,
        'mealTemplateId': mealTemplateId,
        'time': time,
        'ingredientWeights': ingredientWeights,
      },
    );
    return SpecialistAssessmentCustomPlanResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentCustomPlanResponseModel> addWorkout({
    required String assessmentId,
    required int dayNumber,
    required String exerciseId,
    required int sets,
    required int reps,
    required int restDuration,
    required String time,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.addSpecialistDayWorkout(assessmentId, dayNumber),
      data: {
        'exerciseId': exerciseId,
        'sets': sets,
        'reps': reps,
        'restDuration': restDuration,
        'time': time,
      },
    );
    return SpecialistAssessmentCustomPlanResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentCustomPlanResponseModel> addActivity({
    required String assessmentId,
    required int dayNumber,
    required String activityId,
    required int goal,
    required String time,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.addSpecialistDayActivity(assessmentId, dayNumber),
      data: {
        'activityId': activityId,
        'goal': goal,
        'time': time,
      },
    );
    return SpecialistAssessmentCustomPlanResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentCustomPlanResponseModel> updateMeal({
    required String assessmentId,
    required int dayNumber,
    required String mealId,
    required String mealCategoryId,
    required String mealTemplateId,
    required String time,
    required List<Map<String, dynamic>> ingredientWeights,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.updateSpecialistDayMeal(assessmentId, dayNumber, mealId),
      data: {
        'mealCategoryId': mealCategoryId,
        'mealTemplateId': mealTemplateId,
        'time': time,
        'ingredientWeights': ingredientWeights,
      },
    );
    return SpecialistAssessmentCustomPlanResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentCustomPlanResponseModel> updateWorkout({
    required String assessmentId,
    required int dayNumber,
    required String workoutItemId,
    required String exerciseId,
    required int sets,
    required int reps,
    required int restDuration,
    required String time,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.updateSpecialistDayWorkout(assessmentId, dayNumber, workoutItemId),
      data: {
        'exerciseId': exerciseId,
        'sets': sets,
        'reps': reps,
        'restDuration': restDuration,
        'time': time,
      },
    );
    return SpecialistAssessmentCustomPlanResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentCustomPlanResponseModel> updateActivity({
    required String assessmentId,
    required int dayNumber,
    required String activityItemId,
    required String activityId,
    required int goal,
    required String time,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.updateSpecialistDayActivity(assessmentId, dayNumber, activityItemId),
      data: {
        'activityId': activityId,
        'goal': goal,
        'time': time,
      },
    );
    return SpecialistAssessmentCustomPlanResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MealDetailsResponseModel> getMealDetails({
    required String assessmentId,
    required int dayNumber,
    required String mealId,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.mealDetailsNew(assessmentId, dayNumber, mealId),
    );
    return MealDetailsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<WorkoutDetailsResponseModel> getWorkoutDetails({
    required String assessmentId,
    required int dayNumber,
    required String workoutItemId,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.workoutDetails(assessmentId, dayNumber, workoutItemId),
    );
    return WorkoutDetailsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ActivityDetailsResponseModel> getActivityDetails({
    required String assessmentId,
    required int dayNumber,
    required String activityItemId,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.activityDetails(assessmentId, dayNumber, activityItemId),
    );
    return ActivityDetailsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
