import 'package:fitness_day/features/specialist/clients/data/models/client_assessment_model.dart';

sealed class ClientAssessmentsState {
  const ClientAssessmentsState();
}

class ClientAssessmentsInitial extends ClientAssessmentsState {
  const ClientAssessmentsInitial();
}

class ClientAssessmentsLoading extends ClientAssessmentsState {
  const ClientAssessmentsLoading();
}

class ClientAssessmentsSuccess extends ClientAssessmentsState {
  final List<ClientAssessmentModel> upcoming;
  final List<ClientAssessmentModel> previous;

  const ClientAssessmentsSuccess({required this.upcoming, required this.previous});
}

class ClientAssessmentsFailure extends ClientAssessmentsState {
  final String message;

  const ClientAssessmentsFailure(this.message);
}
