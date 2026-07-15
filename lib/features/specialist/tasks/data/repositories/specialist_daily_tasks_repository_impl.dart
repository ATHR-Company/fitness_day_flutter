import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/tasks/data/datasources/specialist_daily_tasks_remote_datasource.dart';
import 'package:fitness_day/features/specialist/tasks/data/models/specialist_daily_task_model.dart';
import 'package:fitness_day/features/specialist/tasks/domain/repositories/specialist_daily_tasks_repository.dart';

class SpecialistDailyTasksRepositoryImpl implements SpecialistDailyTasksRepository {
  final SpecialistDailyTasksRemoteDataSource remoteDataSource;

  SpecialistDailyTasksRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<SpecialistDailyTasksResponseModel>> getDailyTasks({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await remoteDataSource.getDailyTasks(page: page, limit: limit);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
