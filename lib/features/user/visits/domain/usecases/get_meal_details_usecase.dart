import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/visits/data/models/meal_details_model.dart';
import 'package:fitness_day/features/user/visits/domain/repositories/visits_repository.dart';

class GetMealDetailsUseCase {
  final VisitsRepository _repository;

  GetMealDetailsUseCase(this._repository);

  Future<ApiResult<MealDetailsResponseModel>> call(
      String assessmentId, int dayNumber, String mealId) {
    return _repository.getMealDetails(assessmentId, dayNumber, mealId);
  }
}
