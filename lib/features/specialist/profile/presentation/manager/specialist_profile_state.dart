import 'package:fitness_day/features/specialist/profile/data/models/specialist_profile_model.dart';

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

  const SpecialistProfileFailure(this.message);
}

class SpecialistProfileUpdating extends SpecialistProfileState {
  const SpecialistProfileUpdating();
}

class SpecialistProfileUpdateFailure extends SpecialistProfileState {
  final String message;

  const SpecialistProfileUpdateFailure(this.message);
}
