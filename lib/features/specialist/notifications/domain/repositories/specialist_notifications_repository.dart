import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/notifications/data/models/specialist_notification_model.dart';

abstract class SpecialistNotificationsRepository {
  Future<ApiResult<SpecialistNotificationsResponseModel>> getNotifications({
    required int page,
    required int limit,
  });

  Future<ApiResult<SpecialistToggleNotificationReadResponseModel>> toggleReadStatus({
    required String notificationId,
  });
}
