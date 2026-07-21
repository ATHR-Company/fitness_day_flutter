import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/notifications/data/models/user_notification_model.dart';
import 'package:fitness_day/features/user/notifications/domain/repositories/user_notifications_repository.dart';

class GetUserNotificationsUseCase {
  final UserNotificationsRepository repository;

  GetUserNotificationsUseCase(this.repository);

  Future<ApiResult<UserNotificationsResponseModel>> call({
    required int page,
    required int limit,
  }) {
    return repository.getNotifications(page: page, limit: limit);
  }
}
