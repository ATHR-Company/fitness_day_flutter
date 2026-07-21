import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/notifications/data/models/user_notification_model.dart';

abstract class UserNotificationsRepository {
  Future<ApiResult<UserNotificationsResponseModel>> getNotifications({
    required int page,
    required int limit,
  });

  Future<ApiResult<UserToggleNotificationReadResponseModel>> toggleReadStatus({
    required String notificationId,
  });
}
