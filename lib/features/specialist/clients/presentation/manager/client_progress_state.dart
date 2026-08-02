import 'package:fitness_day/features/specialist/clients/data/models/client_progress_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class ClientProgressState {
  const ClientProgressState();
}

class ClientProgressInitial extends ClientProgressState {
  const ClientProgressInitial();
}

class ClientProgressLoading extends ClientProgressState {
  const ClientProgressLoading();
}

class ClientProgressSuccess extends ClientProgressState {
  final ClientProgressDataModel data;
  final int selectedVisitNumber;

  const ClientProgressSuccess({required this.data, required this.selectedVisitNumber});
}

class ClientProgressFailure extends ClientProgressState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const ClientProgressFailure(this.message, {this.error});
}
