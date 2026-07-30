import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/user_home/data/models/walking_sync_model.dart';
import 'package:fitness_day/features/user/user_home/domain/repositories/user_activities_repository.dart';

class SyncWalkingUseCase {
  final UserActivitiesRepository _repository;

  SyncWalkingUseCase(this._repository);

  Future<ApiResult<WalkingSyncResponseModel>> call(
      WalkingSyncRequestModel request) {
    return _repository.syncWalking(request);
  }
}
