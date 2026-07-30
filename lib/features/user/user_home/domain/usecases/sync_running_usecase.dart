import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/user_home/data/models/running_sync_model.dart';
import 'package:fitness_day/features/user/user_home/domain/repositories/user_activities_repository.dart';

class SyncRunningUseCase {
  final UserActivitiesRepository _repository;

  SyncRunningUseCase(this._repository);

  Future<ApiResult<RunningSyncResponseModel>> call(
      RunningSyncRequestModel request) {
    return _repository.syncRunning(request);
  }
}
