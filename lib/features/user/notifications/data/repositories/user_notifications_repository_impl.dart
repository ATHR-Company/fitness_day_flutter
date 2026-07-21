import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/notifications/data/datasources/user_notifications_remote_datasource.dart';
import 'package:fitness_day/features/user/notifications/data/models/user_notification_model.dart';
import 'package:fitness_day/features/user/notifications/domain/repositories/user_notifications_repository.dart';

class UserNotificationsRepositoryImpl implements UserNotificationsRepository {
  final UserNotificationsRemoteDataSource remoteDataSource;

  UserNotificationsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<UserNotificationsResponseModel>> getNotifications({
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
  Future<ApiResult<UserToggleNotificationReadResponseModel>> toggleReadStatus({
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
