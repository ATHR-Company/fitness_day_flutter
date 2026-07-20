import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/notifications/data/datasources/specialist_notifications_remote_datasource.dart';
import 'package:fitness_day/features/specialist/notifications/data/models/specialist_notification_model.dart';
import 'package:fitness_day/features/specialist/notifications/domain/repositories/specialist_notifications_repository.dart';

class SpecialistNotificationsRepositoryImpl implements SpecialistNotificationsRepository {
  final SpecialistNotificationsRemoteDataSource remoteDataSource;

  SpecialistNotificationsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<SpecialistNotificationsResponseModel>> getNotifications({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await remoteDataSource.getNotifications(page: page, limit: limit);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistToggleNotificationReadResponseModel>> toggleReadStatus({
    required String notificationId,
  }) async {
    try {
      final response = await remoteDataSource.toggleReadStatus(notificationId: notificationId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
