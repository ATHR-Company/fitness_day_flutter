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

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const AssessmentsError({required this.message, this.error});

  @override
  List<Object?> get props => [message, error];
}
