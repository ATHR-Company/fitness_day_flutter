import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_plan_model.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_details_model.dart';
import 'package:fitness_day/features/user/workout/data/models/complete_workout_set_model.dart';

abstract class WorkoutRemoteDataSource {
  Future<WorkoutPlanResponseModel> getWorkoutPlan(int dayNumber);
  Future<WorkoutDetailsResponseModel> getWorkoutDetails(String workoutItemId);
  Future<CompleteWorkoutSetResponseModel> completeWorkoutSet(
    int dayNumber,
    String workoutItemId,
    int setNumber,
  );
}

class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  final ApiService _apiService;

  WorkoutRemoteDataSourceImpl(this._apiService);

  @override
  Future<WorkoutPlanResponseModel> getWorkoutPlan(int dayNumber) async {
    final response = await _apiService.get(
      ApiEndpoints.workoutPlanDay(dayNumber),
      queryParameters: {'page': 1, 'limit': 100}, // Fetch a full list for display
    );
    return WorkoutPlanResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<WorkoutDetailsResponseModel> getWorkoutDetails(String workoutItemId) async {
    final response = await _apiService.get(
      ApiEndpoints.workoutDetails(workoutItemId),
    );
    return WorkoutDetailsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CompleteWorkoutSetResponseModel> completeWorkoutSet(
    int dayNumber,
    String workoutItemId,
    int setNumber,
  ) async {
    final response = await _apiService.patch(
      ApiEndpoints.completeWorkoutSet(dayNumber, workoutItemId, setNumber),
    );
    return CompleteWorkoutSetResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
