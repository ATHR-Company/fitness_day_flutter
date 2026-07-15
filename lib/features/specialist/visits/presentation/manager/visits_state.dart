import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_history_model.dart';

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

  const VisitsFailure(this.message);
}

class VisitsLoadingMore extends VisitsState {
  final List<SpecialistAssessmentHistoryItemModel> visits;

  const VisitsLoadingMore(this.visits);
}
