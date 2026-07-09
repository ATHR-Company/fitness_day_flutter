import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_details_model.dart';

class GetWorkoutDetailsUseCase {
  final WorkoutRepository _repository;

  GetWorkoutDetailsUseCase(this._repository);

  Future<ApiResult<WorkoutDetailsResponseModel>> call(String workoutItemId) {
    return _repository.getWorkoutDetails(workoutItemId);
  }
}
