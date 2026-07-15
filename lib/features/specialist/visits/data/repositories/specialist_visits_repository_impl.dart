import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/datasources/specialist_visits_remote_datasource.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_history_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_visit_data_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_start_visit_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_update_goal_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_update_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_plan_lookups_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';

class SpecialistVisitsRepositoryImpl implements SpecialistVisitsRepository {
  final SpecialistVisitsRemoteDataSource remoteDataSource;

  SpecialistVisitsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<SpecialistAssessmentHistoryResponseModel>> getAssessmentHistory({
    required String type,
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final response = await remoteDataSource.getAssessmentHistory(
        type: type,
        page: page,
        limit: limit,
        search: search,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistAssessmentVisitDataResponseModel>> getVisitData({
    required String assessmentId,
  }) async {
    try {
      final response = await remoteDataSource.getVisitData(assessmentId: assessmentId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistAssessmentHealthReportResponseModel>> getHealthReport({
    required String assessmentId,
  }) async {
    try {
      final response = await remoteDataSource.getHealthReport(assessmentId: assessmentId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> getCustomPlan({
    required String assessmentId,
    required int dayNumber,
  }) async {
    try {
      final response = await remoteDataSource.getCustomPlan(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistStartVisitResponseModel>> startVisit({
    required String assessmentId,
  }) async {
    try {
      final response = await remoteDataSource.startVisit(assessmentId: assessmentId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistUpdateGoalResponseModel>> updateGoal({
    required String assessmentId,
    required String goal,
  }) async {
    try {
      final response = await remoteDataSource.updateGoal(
        assessmentId: assessmentId,
        goal: goal,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
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
  }) async {
    try {
      final response = await remoteDataSource.updateHealthReport(
        assessmentId: assessmentId,
        weight: weight,
        height: height,
        bmi: bmi,
        bmr: bmr,
        fatWeight: fatWeight,
        fatPercentage: fatPercentage,
        muscleWeight: muscleWeight,
        musclePercentage: musclePercentage,
        protein: protein,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> updateCustomPlan({
    required String assessmentId,
    required int dayNumber,
    required Map<String, dynamic> planData,
  }) async {
    try {
      final response = await remoteDataSource.updateCustomPlan(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        planData: planData,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<List<SpecialistMealCategoryModel>>> getMealCategories() async {
    try {
      final response = await remoteDataSource.getMealCategories();
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<List<SpecialistMealTemplateModel>>> getMealTemplates({
    required String categoryId,
  }) async {
    try {
      final response = await remoteDataSource.getMealTemplates(categoryId: categoryId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<List<SpecialistActivityLookupModel>>> getActivities() async {
    try {
      final response = await remoteDataSource.getActivities();
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<List<SpecialistExerciseLookupModel>>> getExercises() async {
    try {
      final response = await remoteDataSource.getExercises();
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> addMeal({
    required String assessmentId,
    required int dayNumber,
    required String mealCategoryId,
    required String mealTemplateId,
    required String time,
    required List<Map<String, dynamic>> ingredientWeights,
  }) async {
    try {
      final response = await remoteDataSource.addMeal(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        mealCategoryId: mealCategoryId,
        mealTemplateId: mealTemplateId,
        time: time,
        ingredientWeights: ingredientWeights,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> addWorkout({
    required String assessmentId,
    required int dayNumber,
    required String exerciseId,
    required int sets,
    required int reps,
    required int restDuration,
    required String time,
  }) async {
    try {
      final response = await remoteDataSource.addWorkout(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        exerciseId: exerciseId,
        sets: sets,
        reps: reps,
        restDuration: restDuration,
        time: time,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> addActivity({
    required String assessmentId,
    required int dayNumber,
    required String activityId,
    required int goal,
    required String time,
  }) async {
    try {
      final response = await remoteDataSource.addActivity(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        activityId: activityId,
        goal: goal,
        time: time,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
