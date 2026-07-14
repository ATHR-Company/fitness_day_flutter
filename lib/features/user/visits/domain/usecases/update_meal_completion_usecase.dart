import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/visits/data/models/update_meal_completion_model.dart';
import 'package:fitness_day/features/user/visits/domain/repositories/visits_repository.dart';

class UpdateMealCompletionUseCase {
  final VisitsRepository _repository;

  UpdateMealCompletionUseCase(this._repository);

  Future<ApiResult<UpdateMealCompletionResponseModel>> call(
      String assessmentId, int dayNumber, String mealId, bool isCompleted) {
    return _repository.updateMealCompletionStatus(
        assessmentId, dayNumber, mealId, isCompleted);
  }
}
