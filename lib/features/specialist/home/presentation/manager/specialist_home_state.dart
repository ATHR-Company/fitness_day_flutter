import 'package:fitness_day/features/specialist/home/data/models/specialist_home_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class SpecialistHomeState {
  const SpecialistHomeState();
}

class SpecialistHomeInitial extends SpecialistHomeState {
  const SpecialistHomeInitial();
}

class SpecialistHomeLoading extends SpecialistHomeState {
  const SpecialistHomeLoading();
}

class SpecialistHomeSuccess extends SpecialistHomeState {
  final SpecialistHomeDataModel data;

  const SpecialistHomeSuccess(this.data);
}

class SpecialistHomeFailure extends SpecialistHomeState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const SpecialistHomeFailure(this.message, {this.error});
}
