import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_history_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class VisitsState {
  const VisitsState();
}

class VisitsInitial extends VisitsState {
  const VisitsInitial();
}

class VisitsLoading extends VisitsState {
  const VisitsLoading();
}

class VisitsSuccess extends VisitsState {
  final List<SpecialistAssessmentHistoryItemModel> visits;
  final bool hasReachedMax;

  const VisitsSuccess({
    required this.visits,
    required this.hasReachedMax,
  });
}

class VisitsFailure extends VisitsState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const VisitsFailure(this.message, {this.error});
}

class VisitsLoadingMore extends VisitsState {
  final List<SpecialistAssessmentHistoryItemModel> visits;

  const VisitsLoadingMore(this.visits);
}
