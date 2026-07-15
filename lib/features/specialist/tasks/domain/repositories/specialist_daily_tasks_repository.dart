import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/tasks/data/models/specialist_daily_task_model.dart';

abstract class SpecialistDailyTasksRepository {
  Future<ApiResult<SpecialistDailyTasksResponseModel>> getDailyTasks({
    required int page,
    required int limit,
  });
}
