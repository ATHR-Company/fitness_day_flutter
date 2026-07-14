import 'package:fitness_day/features/specialist/home/data/models/specialist_home_model.dart';

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

  const SpecialistHomeFailure(this.message);
}
