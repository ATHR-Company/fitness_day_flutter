import 'package:fitness_day/features/specialist/notifications/data/models/specialist_notification_model.dart';

sealed class SpecialistNotificationsState {
  const SpecialistNotificationsState();
}

class SpecialistNotificationsInitial extends SpecialistNotificationsState {
  const SpecialistNotificationsInitial();
}

class SpecialistNotificationsLoading extends SpecialistNotificationsState {
  const SpecialistNotificationsLoading();
}

class SpecialistNotificationsSuccess extends SpecialistNotificationsState {
  final List<SpecialistNotificationItemModel> notifications;
  final bool hasReachedMax;

  const SpecialistNotificationsSuccess({
    required this.notifications,
    required this.hasReachedMax,
  });
}

class SpecialistNotificationsFailure extends SpecialistNotificationsState {
  final String message;

  const SpecialistNotificationsFailure(this.message);
}

class SpecialistNotificationsLoadingMore extends SpecialistNotificationsState {
  final List<SpecialistNotificationItemModel> notifications;

  const SpecialistNotificationsLoadingMore(this.notifications);
}
