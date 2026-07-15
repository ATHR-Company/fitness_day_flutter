import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/specialist/tasks/data/models/specialist_daily_task_model.dart';

abstract class SpecialistDailyTasksRemoteDataSource {
  Future<SpecialistDailyTasksResponseModel> getDailyTasks({
    required int page,
    required int limit,
  });
}

class SpecialistDailyTasksRemoteDataSourceImpl implements SpecialistDailyTasksRemoteDataSource {
  final ApiService _apiService;

  SpecialistDailyTasksRemoteDataSourceImpl(this._apiService);

  @override
  Future<SpecialistDailyTasksResponseModel> getDailyTasks({
    required int page,
    required int limit,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistDailyTasks,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return SpecialistDailyTasksResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
