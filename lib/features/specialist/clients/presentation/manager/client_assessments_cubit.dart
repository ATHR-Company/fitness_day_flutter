import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/domain/usecases/get_upcoming_assessments_usecase.dart';
import 'package:fitness_day/features/specialist/clients/domain/usecases/get_previous_assessments_usecase.dart';
import 'client_assessments_state.dart';

class ClientAssessmentsCubit extends Cubit<ClientAssessmentsState> {
  final GetUpcomingAssessmentsUseCase _getUpcoming;
  final GetPreviousAssessmentsUseCase _getPrevious;

  ClientAssessmentsCubit(this._getUpcoming, this._getPrevious)
      : super(const ClientAssessmentsInitial());

  Future<void> loadAssessments({required String userId}) async {
    emit(const ClientAssessmentsLoading());

    final results = await Future.wait([
      _getUpcoming(userId: userId),
      _getPrevious(userId: userId),
    ]);

    final upcomingResult = results[0];
    final previousResult = results[1];

    // If either fails, emit failure
    if (upcomingResult case FailureResult(:final failure)) {
      emit(ClientAssessmentsFailure(failure.message));
      return;
    }
    if (previousResult case FailureResult(:final failure)) {
      emit(ClientAssessmentsFailure(failure.message));
      return;
    }

    final upcoming = (upcomingResult as Success).data.data ?? [];
    final previous = (previousResult as Success).data.data ?? [];

    emit(ClientAssessmentsSuccess(upcoming: upcoming, previous: previous));
  }
}
