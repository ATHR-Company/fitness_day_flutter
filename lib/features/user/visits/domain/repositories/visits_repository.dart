import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:fitness_day/features/user/visits/data/models/meal_details_model.dart';

abstract class VisitsRepository {
  Future<ApiResult<DietPlanResponseModel>> getDietPlan(int day);
  Future<ApiResult<MealDetailsResponseModel>> getMealDetails(String mealId);
}
