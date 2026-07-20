import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/notifications/data/models/specialist_notification_model.dart';
import 'package:fitness_day/features/specialist/notifications/domain/repositories/specialist_notifications_repository.dart';

class GetSpecialistNotificationsUseCase {
  final SpecialistNotificationsRepository repository;

  GetSpecialistNotificationsUseCase(this.repository);

  Future<ApiResult<SpecialistNotificationsResponseModel>> call({
    required int page,
    required int limit,
  }) {
    return repository.getNotifications(page: page, limit: limit);
  }
}
