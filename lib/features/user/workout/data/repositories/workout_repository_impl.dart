import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/features/user/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_day/features/user/workout/data/datasources/workout_remote_datasource.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_plan_model.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_details_model.dart';
import 'package:fitness_day/features/user/workout/data/models/complete_workout_set_model.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource _remoteDataSource;

  WorkoutRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<WorkoutPlanResponseModel>> getWorkoutPlan(int dayNumber) async {
    try {
      final response = await _remoteDataSource.getWorkoutPlan(dayNumber);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<WorkoutDetailsResponseModel>> getWorkoutDetails(String workoutItemId) async {
    try {
      final response = await _remoteDataSource.getWorkoutDetails(workoutItemId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<CompleteWorkoutSetResponseModel>> completeWorkoutSet(
    int dayNumber,
    String workoutItemId,
    int setNumber,
  ) async {
    try {
      final response = await _remoteDataSource.completeWorkoutSet(dayNumber, workoutItemId, setNumber);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
