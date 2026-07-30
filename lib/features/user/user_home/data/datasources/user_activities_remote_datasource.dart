import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/user/user_home/data/models/running_sync_model.dart';
import 'package:fitness_day/features/user/user_home/data/models/walking_sync_model.dart';

/// Live-session progress reporting for the walking and running activities.
///
/// Throws `DioException` on failure — mapping to a `Failure` is the
/// repository's job.
abstract class UserActivitiesRemoteDataSource {
  Future<WalkingSyncResponseModel> syncWalking(WalkingSyncRequestModel request);

  Future<RunningSyncResponseModel> syncRunning(RunningSyncRequestModel request);
}

class UserActivitiesRemoteDataSourceImpl
    implements UserActivitiesRemoteDataSource {
  final ApiService _apiService;

  UserActivitiesRemoteDataSourceImpl(this._apiService);

  @override
  Future<WalkingSyncResponseModel> syncWalking(
      WalkingSyncRequestModel request) async {
    final response = await _apiService.post(
      ApiEndpoints.syncWalking,
      data: request.toJson(),
    );
    return WalkingSyncResponseModel.fromJson(_body(response.data));
  }

  @override
  Future<RunningSyncResponseModel> syncRunning(
      RunningSyncRequestModel request) async {
    final response = await _apiService.post(
      ApiEndpoints.syncRunning,
      data: request.toJson(),
    );
    return RunningSyncResponseModel.fromJson(_body(response.data));
  }

  /// A sync is acknowledged by its status code; the body only carries extras
  /// (calories). An empty or unexpected body must not turn an accepted sync
  /// into a failure, or the attempt would be retried and counted twice.
  Map<String, dynamic> _body(dynamic data) =>
      data is Map<String, dynamic> ? data : const <String, dynamic>{};
}
