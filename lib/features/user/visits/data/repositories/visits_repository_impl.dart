import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/features/user/visits/data/datasources/visits_remote_datasource.dart';
import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:fitness_day/features/user/visits/data/models/meal_details_model.dart';
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
  Future<ApiResult<MealDetailsResponseModel>> getMealDetails(String mealId) async {
    try {
      final response = await _remoteDataSource.getMealDetails(mealId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
