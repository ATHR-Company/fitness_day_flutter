import 'package:fitness_day/features/specialist/clients/data/models/client_progress_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class UserProgressState {
  const UserProgressState();
}

class UserProgressInitial extends UserProgressState {
  const UserProgressInitial();
}

class UserProgressLoading extends UserProgressState {
  const UserProgressLoading();
}

class UserProgressSuccess extends UserProgressState {
  final ClientProgressDataModel data;
  final int selectedVisitNumber;

  const UserProgressSuccess({required this.data, required this.selectedVisitNumber});
}

class UserProgressFailure extends UserProgressState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const UserProgressFailure(this.message, {this.error});
}
