part of 'assessment_details_cubit.dart';

sealed class AssessmentDetailsState {}

class AssessmentDetailsInitial extends AssessmentDetailsState {}

class AssessmentDetailsLoading extends AssessmentDetailsState {}

class AssessmentDetailsLoaded extends AssessmentDetailsState {
  final Map<String, dynamic>? summaryData;
  final Map<String, dynamic>? dayData;
  AssessmentDetailsLoaded({this.summaryData, this.dayData});
}

class AssessmentDetailsError extends AssessmentDetailsState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;
  AssessmentDetailsError(this.message, {this.error});
}
