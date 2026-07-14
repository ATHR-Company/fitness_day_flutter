import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:fitness_day/features/user/visits/data/models/meal_details_model.dart';
import 'package:fitness_day/features/user/visits/data/models/update_meal_completion_model.dart';

abstract class VisitsRepository {
  Future<ApiResult<DietPlanResponseModel>> getDietPlan(int day);

  Future<ApiResult<MealDetailsResponseModel>> getMealDetails(
      String assessmentId, int dayNumber, String mealId);

  Future<ApiResult<ActivityDetailsResponseModel>> getActivityDetails(
      String assessmentId, int dayNumber, String activityId,
      {String period = 'daily'});

  Future<ApiResult<UpdateMealCompletionResponseModel>> updateMealCompletionStatus(
      String assessmentId, int dayNumber, String mealId, bool isCompleted);
}
