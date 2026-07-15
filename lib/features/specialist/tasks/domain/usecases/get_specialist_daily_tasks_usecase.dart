import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/tasks/data/models/specialist_daily_task_model.dart';
import 'package:fitness_day/features/specialist/tasks/domain/repositories/specialist_daily_tasks_repository.dart';

class GetSpecialistDailyTasksUseCase {
  final SpecialistDailyTasksRepository repository;

  GetSpecialistDailyTasksUseCase(this.repository);

  Future<ApiResult<SpecialistDailyTasksResponseModel>> call({
    required int page,
    required int limit,
  }) {
    return repository.getDailyTasks(page: page, limit: limit);
  }
}
