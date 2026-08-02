import 'package:fitness_day/features/specialist/clients/data/models/specialist_client_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class SpecialistClientProfileState {
  const SpecialistClientProfileState();
}

class SpecialistClientProfileInitial extends SpecialistClientProfileState {
  const SpecialistClientProfileInitial();
}

class SpecialistClientProfileLoading extends SpecialistClientProfileState {
  const SpecialistClientProfileLoading();
}

class SpecialistClientProfileSuccess extends SpecialistClientProfileState {
  final SpecialistClientProfileDataModel data;

  const SpecialistClientProfileSuccess(this.data);
}

class SpecialistClientProfileFailure extends SpecialistClientProfileState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const SpecialistClientProfileFailure(this.message, {this.error});
}
