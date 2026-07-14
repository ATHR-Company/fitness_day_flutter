import 'package:fitness_day/features/specialist/clients/data/models/client_progress_model.dart';

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

  const ClientProgressFailure(this.message);
}
