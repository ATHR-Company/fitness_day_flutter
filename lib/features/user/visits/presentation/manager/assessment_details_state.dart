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
  AssessmentDetailsError(this.message);
}
