import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/domain/usecases/get_client_progress_usecase.dart';
import 'client_progress_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class ClientProgressCubit extends Cubit<ClientProgressState> {
  final GetClientProgressUseCase _getProgress;

  ClientProgressCubit(this._getProgress) : super(const ClientProgressInitial());

  Future<void> loadProgress({
    required String userId,
    int visitNumber = 1,
  }) async {
    emit(const ClientProgressLoading());

    final result = await _getProgress(userId: userId, visitNumber: visitNumber);

    if (result case FailureResult(:final failure)) {
      emit(ClientProgressFailure(failure.message, error: AppError.from(failure)));
      return;
    }

    final data = (result as Success).data.data;
    if (data == null) {
      emit(const ClientProgressFailure("No data returned"));
      return;
    }

    emit(ClientProgressSuccess(data: data, selectedVisitNumber: visitNumber));
  }
}
