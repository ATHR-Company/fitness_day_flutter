import 'package:fitness_day/features/specialist/clients/data/models/client_progress_model.dart';

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

  const UserProgressFailure(this.message);
}
