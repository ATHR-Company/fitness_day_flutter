import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_plan_model.dart';

class GetWorkoutPlanUseCase {
  final WorkoutRepository _repository;

  GetWorkoutPlanUseCase(this._repository);

  Future<ApiResult<WorkoutPlanResponseModel>> call(int dayNumber) {
    return _repository.getWorkoutPlan(dayNumber);
  }
}
