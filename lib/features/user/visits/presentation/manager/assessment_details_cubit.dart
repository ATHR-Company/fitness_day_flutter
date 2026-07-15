import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/visits/domain/repositories/visits_repository.dart';

part 'assessment_details_state.dart';

class AssessmentDetailsCubit extends Cubit<AssessmentDetailsState> {
  final VisitsRepository _repository;

  AssessmentDetailsCubit(this._repository) : super(AssessmentDetailsInitial());

  Map<String, dynamic>? _summaryData;
  Map<String, dynamic>? _dayData;

  Future<void> getInitialData(String assessmentId, int dayNumber) async {
    emit(AssessmentDetailsLoading());
    final summaryResult = await _repository.getAssessmentDetails(assessmentId);
    final dayResult = await _repository.getAssessmentDetails(assessmentId, dayNumber: dayNumber);
    
    if (summaryResult is Success<Map<String, dynamic>>) {
      _summaryData = summaryResult.data;
    }
    if (dayResult is Success<Map<String, dynamic>>) {
      _dayData = dayResult.data;
    }
    
    if (summaryResult is FailureResult<Map<String, dynamic>> || dayResult is FailureResult<Map<String, dynamic>>) {
      final FailureResult<Map<String, dynamic>> failure = summaryResult is FailureResult<Map<String, dynamic>>
          ? summaryResult
          : (dayResult as FailureResult<Map<String, dynamic>>);
      emit(AssessmentDetailsError(failure.failure.message));
    } else {
      emit(AssessmentDetailsLoaded(summaryData: _summaryData, dayData: _dayData));
    }
  }

  Future<void> getDayDetails(String assessmentId, int dayNumber) async {
    emit(AssessmentDetailsLoading());
    final result = await _repository.getAssessmentDetails(assessmentId, dayNumber: dayNumber);
    switch (result) {
      case Success(:final data):
        _dayData = data;
        emit(AssessmentDetailsLoaded(summaryData: _summaryData, dayData: _dayData));
      case FailureResult(:final failure):
        emit(AssessmentDetailsError(failure.message));
    }
  }
}
