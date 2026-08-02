import 'package:fitness_day/features/specialist/clients/data/models/specialist_client_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class SpecialistClientsState {
  const SpecialistClientsState();
}

class SpecialistClientsInitial extends SpecialistClientsState {
  const SpecialistClientsInitial();
}

class SpecialistClientsLoading extends SpecialistClientsState {
  const SpecialistClientsLoading();
}

class SpecialistClientsSuccess extends SpecialistClientsState {
  final SpecialistClientsListResponseModel data;

  const SpecialistClientsSuccess(this.data);
}

class SpecialistClientsFailure extends SpecialistClientsState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const SpecialistClientsFailure(this.message, {this.error});
}
