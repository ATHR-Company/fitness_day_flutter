import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/specialist/notifications/data/models/specialist_notification_model.dart';

abstract class SpecialistNotificationsRemoteDataSource {
  Future<SpecialistNotificationsResponseModel> getNotifications({
    required int page,
    required int limit,
  });

  Future<SpecialistToggleNotificationReadResponseModel> toggleReadStatus({
    required String notificationId,
  });
}

class SpecialistNotificationsRemoteDataSourceImpl implements SpecialistNotificationsRemoteDataSource {
  final ApiService _apiService;

  SpecialistNotificationsRemoteDataSourceImpl(this._apiService);

  @override
  Future<SpecialistNotificationsResponseModel> getNotifications({
    required int page,
    required int limit,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistNotifications,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return SpecialistNotificationsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistToggleNotificationReadResponseModel> toggleReadStatus({
    required String notificationId,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.specialistNotificationRead(notificationId),
    );
    return SpecialistToggleNotificationReadResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
