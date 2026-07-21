import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/notifications/data/models/user_notification_model.dart';
import 'package:fitness_day/features/user/notifications/domain/repositories/user_notifications_repository.dart';

class ToggleUserNotificationReadUseCase {
  final UserNotificationsRepository repository;

  ToggleUserNotificationReadUseCase(this.repository);

  Future<ApiResult<UserToggleNotificationReadResponseModel>> call({
    required String notificationId,
  }) {
    return repository.toggleReadStatus(notificationId: notificationId);
  }
}
