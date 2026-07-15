import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_history_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_visit_data_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_start_visit_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_update_goal_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_update_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_plan_lookups_model.dart';

abstract class SpecialistVisitsRepository {
  Future<ApiResult<SpecialistAssessmentHistoryResponseModel>> getAssessmentHistory({
    required String type,
    required int page,
    required int limit,
    String? search,
  });

  Future<ApiResult<SpecialistAssessmentVisitDataResponseModel>> getVisitData({
    required String assessmentId,
  });

  Future<ApiResult<SpecialistAssessmentHealthReportResponseModel>> getHealthReport({
    required String assessmentId,
  });

  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> getCustomPlan({
    required String assessmentId,
    required int dayNumber,
  });

  Future<ApiResult<SpecialistStartVisitResponseModel>> startVisit({
    required String assessmentId,
  });

  Future<ApiResult<SpecialistUpdateGoalResponseModel>> updateGoal({
    required String assessmentId,
    required String goal,
  });

  Future<ApiResult<SpecialistUpdateHealthReportResponseModel>> updateHealthReport({
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

  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> updateCustomPlan({
    required String assessmentId,
    required int dayNumber,
    required Map<String, dynamic> planData,
  });

  Future<ApiResult<List<SpecialistMealCategoryModel>>> getMealCategories();

  Future<ApiResult<List<SpecialistMealTemplateModel>>> getMealTemplates({
    required String categoryId,
  });

  Future<ApiResult<List<SpecialistActivityLookupModel>>> getActivities();

  Future<ApiResult<List<SpecialistExerciseLookupModel>>> getExercises();

  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> addMeal({
    required String assessmentId,
    required int dayNumber,
    required String mealCategoryId,
    required String mealTemplateId,
    required String time,
    required List<Map<String, dynamic>> ingredientWeights,
  });

  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> addWorkout({
    required String assessmentId,
    required int dayNumber,
    required String exerciseId,
    required int sets,
    required int reps,
    required int restDuration,
    required String time,
  });

  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> addActivity({
    required String assessmentId,
    required int dayNumber,
    required String activityId,
    required int goal,
    required String time,
  });
}
