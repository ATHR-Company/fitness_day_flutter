import 'package:fitness_day/features/user/notifications/data/models/user_notification_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class UserNotificationsState {
  const UserNotificationsState();
}

class UserNotificationsInitial extends UserNotificationsState {
  const UserNotificationsInitial();
}

class UserNotificationsLoading extends UserNotificationsState {
  const UserNotificationsLoading();
}

class UserNotificationsSuccess extends UserNotificationsState {
  final List<UserNotificationItemModel> notifications;
  final bool hasReachedMax;

  const UserNotificationsSuccess({
    required this.notifications,
    required this.hasReachedMax,
  });
}

class UserNotificationsFailure extends UserNotificationsState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const UserNotificationsFailure(this.message, {this.error});
}

class UserNotificationsLoadingMore extends UserNotificationsState {
  final List<UserNotificationItemModel> notifications;

  const UserNotificationsLoadingMore(this.notifications);
}
