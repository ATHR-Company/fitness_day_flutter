import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_day/features/user/workout/data/models/complete_workout_set_model.dart';

class CompleteWorkoutSetUseCase {
  final WorkoutRepository _repository;

  CompleteWorkoutSetUseCase(this._repository);

  Future<ApiResult<CompleteWorkoutSetResponseModel>> call({
    required String assessmentId,
    required int dayNumber,
    required String workoutItemId,
    required int setNumber,
  }) {
    return _repository.completeWorkoutSet(assessmentId, dayNumber, workoutItemId, setNumber);
  }
}
