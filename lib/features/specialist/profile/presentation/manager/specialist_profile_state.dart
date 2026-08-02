import 'package:fitness_day/features/specialist/profile/data/models/specialist_profile_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class SpecialistProfileState {
  const SpecialistProfileState();
}

class SpecialistProfileInitial extends SpecialistProfileState {
  const SpecialistProfileInitial();
}

class SpecialistProfileLoading extends SpecialistProfileState {
  const SpecialistProfileLoading();
}

class SpecialistProfileSuccess extends SpecialistProfileState {
  final SpecialistProfileDataModel data;

  const SpecialistProfileSuccess(this.data);
}

class SpecialistProfileFailure extends SpecialistProfileState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const SpecialistProfileFailure(this.message, {this.error});
}

class SpecialistProfileUpdating extends SpecialistProfileState {
  const SpecialistProfileUpdating();
}

class SpecialistProfileUpdateFailure extends SpecialistProfileState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const SpecialistProfileUpdateFailure(this.message, {this.error});
}
