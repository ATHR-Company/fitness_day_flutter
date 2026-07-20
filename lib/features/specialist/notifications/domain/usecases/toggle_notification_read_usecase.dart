import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/notifications/data/models/specialist_notification_model.dart';
import 'package:fitness_day/features/specialist/notifications/domain/repositories/specialist_notifications_repository.dart';

class ToggleNotificationReadUseCase {
  final SpecialistNotificationsRepository repository;

  ToggleNotificationReadUseCase(this.repository);

  Future<ApiResult<SpecialistToggleNotificationReadResponseModel>> call({
    required String notificationId,
  }) {
    return repository.toggleReadStatus(notificationId: notificationId);
  }
}
