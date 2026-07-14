import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:fitness_day/features/user/visits/data/models/meal_details_model.dart';
import 'package:fitness_day/features/user/visits/data/models/update_meal_completion_model.dart';

abstract class VisitsRemoteDataSource {
  Future<DietPlanResponseModel> getDietPlan(int day);
  Future<MealDetailsResponseModel> getMealDetails(
      String assessmentId, int dayNumber, String mealId);
  Future<ActivityDetailsResponseModel> getActivityDetails(
      String assessmentId, int dayNumber, String activityId);
  Future<UpdateMealCompletionResponseModel> updateMealCompletionStatus(
      String assessmentId, int dayNumber, String mealId, bool isCompleted);
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
      String assessmentId, int dayNumber, String activityId) async {
    final response = await _apiService.get(
      ApiEndpoints.activityDetails(assessmentId, dayNumber, activityId),
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
}
