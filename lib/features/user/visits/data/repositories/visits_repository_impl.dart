import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/features/user/visits/data/datasources/visits_remote_datasource.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'package:fitness_day/features/user/visits/data/models/assessment_model.dart';
import 'package:fitness_day/features/user/visits/data/models/branch_model.dart';
import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:fitness_day/features/user/visits/data/models/meal_details_model.dart';
import 'package:fitness_day/features/user/visits/data/models/update_meal_completion_model.dart';
import 'package:fitness_day/features/user/visits/domain/repositories/visits_repository.dart';

class VisitsRepositoryImpl implements VisitsRepository {
  final VisitsRemoteDataSource _remoteDataSource;

  VisitsRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<DietPlanResponseModel>> getDietPlan(int day) async {
    try {
      final response = await _remoteDataSource.getDietPlan(day);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<MealDetailsResponseModel>> getMealDetails(
      String assessmentId, int dayNumber, String mealId) async {
    try {
      final response =
          await _remoteDataSource.getMealDetails(assessmentId, dayNumber, mealId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ActivityDetailsResponseModel>> getActivityDetails(
      String assessmentId, int dayNumber, String activityId,
      {String period = 'daily'}) async {
    try {
      final response = await _remoteDataSource.getActivityDetails(
          assessmentId, dayNumber, activityId,
          period: period);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<UpdateMealCompletionResponseModel>> updateMealCompletionStatus(
      String assessmentId, int dayNumber, String mealId,
      bool isCompleted) async {
    try {
      final response = await _remoteDataSource.updateMealCompletionStatus(
          assessmentId, dayNumber, mealId, isCompleted);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<AssessmentsResponse>> getAssessments(String weekStartFrom, String weekStartTo) async {
    try {
      final response = await _remoteDataSource.getAssessments(weekStartFrom, weekStartTo);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<List<BranchModel>>> getBranches() async {
    try {
      final response = await _remoteDataSource.getBranches();
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<String>> requestAssessmentChange(String assessmentId, {String? type, String? branchId, String? date}) async {
    try {
      final message = await _remoteDataSource.requestAssessmentChange(assessmentId, type: type, branchId: branchId, date: date);
      return Success(message);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> getAssessmentDetails(String assessmentId, {int? dayNumber}) async {
    try {
      final response = await _remoteDataSource.getAssessmentDetails(assessmentId, dayNumber: dayNumber);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
