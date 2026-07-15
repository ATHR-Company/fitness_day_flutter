import 'package:fitness_day/features/specialist/clients/data/models/specialist_client_model.dart';

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

  const SpecialistClientsFailure(this.message);
}
