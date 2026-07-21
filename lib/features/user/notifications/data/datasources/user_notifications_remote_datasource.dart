import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/user/notifications/data/models/user_notification_model.dart';

abstract class UserNotificationsRemoteDataSource {
  Future<UserNotificationsResponseModel> getNotifications({
    required int page,
    required int limit,
  });

  Future<UserToggleNotificationReadResponseModel> toggleReadStatus({
    required String notificationId,
  });
}

class UserNotificationsRemoteDataSourceImpl implements UserNotificationsRemoteDataSource {
  final ApiService _apiService;

  UserNotificationsRemoteDataSourceImpl(this._apiService);

  @override
  Future<UserNotificationsResponseModel> getNotifications({
    required int page,
    required int limit,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return UserNotificationsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserToggleNotificationReadResponseModel> toggleReadStatus({
    required String notificationId,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.notificationRead(notificationId),
    );
    return UserToggleNotificationReadResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
