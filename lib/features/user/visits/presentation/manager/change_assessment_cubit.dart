import 'package:equatable/equatable.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/features/user/visits/data/models/branch_model.dart';
import 'package:fitness_day/features/user/visits/domain/repositories/visits_repository.dart';
import 'package:fitness_day/core/errors/app_error.dart';

part 'change_assessment_state.dart';

class ChangeAssessmentCubit extends Cubit<ChangeAssessmentState> {
  final VisitsRepository _visitsRepository;

  ChangeAssessmentCubit(this._visitsRepository) : super(ChangeAssessmentInitial());

  Future<void> fetchBranches() async {
    emit(ChangeAssessmentLoading());
    final result = await _visitsRepository.getBranches();
    
    if (result is Success<List<BranchModel>>) {
      emit(BranchesLoaded(branches: result.data));
    } else if (result is FailureResult<List<BranchModel>>) {
      emit(ChangeAssessmentError(message: result.failure.message, error: AppError.from(result.failure)));
    }
  }

  Future<void> submitChangeRequest({required String assessmentId, String? type, String? branchId, String? date}) async {
    emit(ChangeAssessmentLoading());
    final result = await _visitsRepository.requestAssessmentChange(
      assessmentId,
      type: type,
      branchId: branchId,
      date: date,
    );
    
    if (result is Success<String>) {
      emit(ChangeAssessmentSuccess(message: result.data));
    } else if (result is FailureResult<String>) {
      emit(ChangeAssessmentError(message: result.failure.message, error: AppError.from(result.failure)));
    }
  }
}
