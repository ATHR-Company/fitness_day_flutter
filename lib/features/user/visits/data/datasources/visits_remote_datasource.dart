import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:fitness_day/features/user/visits/data/models/meal_details_model.dart';

abstract class VisitsRemoteDataSource {
  Future<DietPlanResponseModel> getDietPlan(int day);
  Future<MealDetailsResponseModel> getMealDetails(String mealId);
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
  Future<MealDetailsResponseModel> getMealDetails(String mealId) async {
    final response = await _apiService.get(
      '${ApiEndpoints.mealDetails}/$mealId',
    );
    return MealDetailsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
