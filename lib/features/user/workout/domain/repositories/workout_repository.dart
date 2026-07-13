import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_plan_model.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_details_model.dart';
import 'package:fitness_day/features/user/workout/data/models/complete_workout_set_model.dart';

abstract class WorkoutRepository {
  Future<ApiResult<WorkoutPlanResponseModel>> getWorkoutPlan(int dayNumber);
  Future<ApiResult<WorkoutDetailsResponseModel>> getWorkoutDetails(
      String assessmentId, int dayNumber, String workoutItemId);
  Future<ApiResult<CompleteWorkoutSetResponseModel>> completeWorkoutSet(
    int dayNumber,
    String workoutItemId,
    int setNumber,
  );
}
