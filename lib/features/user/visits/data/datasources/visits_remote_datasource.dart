import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:fitness_day/features/user/visits/data/models/meal_details_model.dart';
import 'package:fitness_day/features/user/visits/data/models/update_meal_completion_model.dart';

import 'package:fitness_day/features/user/visits/data/models/assessment_model.dart';
import 'package:fitness_day/features/user/visits/data/models/branch_model.dart';

abstract class VisitsRemoteDataSource {
  Future<DietPlanResponseModel> getDietPlan(int day);
  Future<MealDetailsResponseModel> getMealDetails(
      String assessmentId, int dayNumber, String mealId);
  Future<ActivityDetailsResponseModel> getActivityDetails(
      String assessmentId, int dayNumber, String activityId,
      {String period = 'daily'});
  Future<UpdateMealCompletionResponseModel> updateMealCompletionStatus(
      String assessmentId, int dayNumber, String mealId, bool isCompleted);
      
  Future<AssessmentsResponse> getAssessments(String weekStartFrom, String weekStartTo);
  Future<List<BranchModel>> getBranches();
  Future<String> requestAssessmentChange(String assessmentId, {String? type, String? branchId, String? date});
  Future<Map<String, dynamic>> getAssessmentDetails(String assessmentId, {int? dayNumber});
}

class VisitsRemoteDataSourceImpl implements VisitsRemoteDataSource {
  final ApiService _apiService;

  VisitsRemoteDataSourceImpl(this._apiService);

  @override
  Future<DietPlanResponseModel> getDietPlan(int day) async {
    final response = await _apiService.get(
      ApiEndpoints.dietPlan,
      queryParameters: {'day': day},
    );
    return DietPlanResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MealDetailsResponseModel> getMealDetails(
      String assessmentId, int dayNumber, String mealId) async {
    final response = await _apiService.get(
      ApiEndpoints.mealDetailsNew(assessmentId, dayNumber, mealId),
    );
    return MealDetailsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ActivityDetailsResponseModel> getActivityDetails(
      String assessmentId, int dayNumber, String activityId,
      {String period = 'daily'}) async {
    final response = await _apiService.get(
      ApiEndpoints.activityDetails(assessmentId, dayNumber, activityId),
      queryParameters: {'period': period},
    );
    return ActivityDetailsResponseModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<UpdateMealCompletionResponseModel> updateMealCompletionStatus(
      String assessmentId, int dayNumber, String mealId, bool isCompleted) async {
    final response = await _apiService.patch(
      ApiEndpoints.mealDetailsNew(assessmentId, dayNumber, mealId),
      data: {'isCompleted': isCompleted},
    );
    return UpdateMealCompletionResponseModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<AssessmentsResponse> getAssessments(String weekStartFrom, String weekStartTo) async {
    final response = await _apiService.get(
      ApiEndpoints.userAssessments,
      queryParameters: {
        'weekStartFrom': weekStartFrom,
        'weekStartTo': weekStartTo,
        'page': 1,
        'limit': 100,
      },
    );
    return AssessmentsResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<BranchModel>> getBranches() async {
    final response = await _apiService.get(ApiEndpoints.branches);
    final data = response.data['data'] as List;
    return data.map((e) => BranchModel.fromJson(e)).toList();
  }

  @override
  Future<String> requestAssessmentChange(String assessmentId, {String? type, String? branchId, String? date}) async {
    final Map<String, dynamic> data = {
      'assessmentId': assessmentId,
    };
    if (type != null) {
      data['requestedPlacementType'] = type;
    }
    if (branchId != null) {
      data['requestedBranchId'] = branchId;
    }
    if (date != null) {
      data['requestedWeekStart'] = date;
    }
    final response = await _apiService.post(ApiEndpoints.assessmentChangeRequests, data: data);
    return response.data['message'] as String? ?? 'تم الإرسال بنجاح';
  }

  @override
  Future<Map<String, dynamic>> getAssessmentDetails(String assessmentId, {int? dayNumber}) async {
    final Map<String, dynamic> queryParams = {};
    if (dayNumber != null) {
      queryParams['dayNumber'] = dayNumber;
    }
    final response = await _apiService.get(
      ApiEndpoints.assessmentDetails(assessmentId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return response.data as Map<String, dynamic>;
  }
}
