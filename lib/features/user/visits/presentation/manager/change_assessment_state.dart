part of 'change_assessment_cubit.dart';

abstract class ChangeAssessmentState extends Equatable {
  const ChangeAssessmentState();

  @override
  List<Object?> get props => [];
}

class ChangeAssessmentInitial extends ChangeAssessmentState {}

class ChangeAssessmentLoading extends ChangeAssessmentState {}

class BranchesLoaded extends ChangeAssessmentState {
  final List<BranchModel> branches;

  const BranchesLoaded({required this.branches});

  @override
  List<Object?> get props => [branches];
}

class ChangeAssessmentSuccess extends ChangeAssessmentState {
  final String message;

  const ChangeAssessmentSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChangeAssessmentError extends ChangeAssessmentState {
  final String message;

  const ChangeAssessmentError({required this.message});

  @override
  List<Object?> get props => [message];
}
