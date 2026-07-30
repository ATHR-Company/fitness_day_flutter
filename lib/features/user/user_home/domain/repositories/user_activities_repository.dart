import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/user_home/data/models/running_sync_model.dart';
import 'package:fitness_day/features/user/user_home/data/models/walking_sync_model.dart';

abstract class UserActivitiesRepository {
  Future<ApiResult<WalkingSyncResponseModel>> syncWalking(
      WalkingSyncRequestModel request);

  Future<ApiResult<RunningSyncResponseModel>> syncRunning(
      RunningSyncRequestModel request);
}
