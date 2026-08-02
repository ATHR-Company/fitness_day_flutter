import 'package:fitness_day/features/specialist/clients/data/models/client_assessment_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

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

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const ClientAssessmentsFailure(this.message, {this.error});
}
