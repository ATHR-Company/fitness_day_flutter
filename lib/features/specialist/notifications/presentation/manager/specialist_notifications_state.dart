import 'package:fitness_day/features/specialist/notifications/data/models/specialist_notification_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

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

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const SpecialistNotificationsFailure(this.message, {this.error});
}

class SpecialistNotificationsLoadingMore extends SpecialistNotificationsState {
  final List<SpecialistNotificationItemModel> notifications;

  const SpecialistNotificationsLoadingMore(this.notifications);
}
