part of 'assessments_cubit.dart';

abstract class AssessmentsState extends Equatable {
  const AssessmentsState();

  @override
  List<Object?> get props => [];
}

class AssessmentsInitial extends AssessmentsState {}

class AssessmentsLoading extends AssessmentsState {}

class AssessmentsLoaded extends AssessmentsState {
  final AssessmentsResponse response;
  final DateTime currentWeekStart;

  const AssessmentsLoaded({required this.response, required this.currentWeekStart});

  @override
  List<Object?> get props => [response, currentWeekStart];
}

class AssessmentsError extends AssessmentsState {
  final String message;

  const AssessmentsError({required this.message});

  @override
  List<Object?> get props => [message];
}
