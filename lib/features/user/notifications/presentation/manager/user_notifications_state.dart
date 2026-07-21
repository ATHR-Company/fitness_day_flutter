import 'package:fitness_day/features/user/notifications/data/models/user_notification_model.dart';

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

  const UserNotificationsFailure(this.message);
}

class UserNotificationsLoadingMore extends UserNotificationsState {
  final List<UserNotificationItemModel> notifications;

  const UserNotificationsLoadingMore(this.notifications);
}
