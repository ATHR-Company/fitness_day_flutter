import 'package:fitness_day/features/specialist/clients/data/models/specialist_client_model.dart';

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

  const SpecialistClientProfileFailure(this.message);
}
