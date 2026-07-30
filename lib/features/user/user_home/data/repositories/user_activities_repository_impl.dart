import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/user_home/data/datasources/user_activities_remote_datasource.dart';
import 'package:fitness_day/features/user/user_home/data/models/running_sync_model.dart';
import 'package:fitness_day/features/user/user_home/data/models/walking_sync_model.dart';
import 'package:fitness_day/features/user/user_home/domain/repositories/user_activities_repository.dart';

class UserActivitiesRepositoryImpl implements UserActivitiesRepository {
  final UserActivitiesRemoteDataSource _remoteDataSource;

  UserActivitiesRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<WalkingSyncResponseModel>> syncWalking(
      WalkingSyncRequestModel request) async {
    try {
      final response = await _remoteDataSource.syncWalking(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<RunningSyncResponseModel>> syncRunning(
      RunningSyncRequestModel request) async {
    try {
      final response = await _remoteDataSource.syncRunning(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
