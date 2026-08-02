import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/progress/domain/usecases/get_user_progress_usecase.dart';
import 'user_progress_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class UserProgressCubit extends Cubit<UserProgressState> {
  final GetUserProgressUseCase _getProgress;

  UserProgressCubit(this._getProgress) : super(const UserProgressInitial());

  Future<void> loadProgress({int visitNumber = 1}) async {
    emit(const UserProgressLoading());

    final result = await _getProgress(visitNumber: visitNumber);

    if (result case FailureResult(:final failure)) {
      emit(UserProgressFailure(failure.message, error: AppError.from(failure)));
      return;
    }

    final data = (result as Success).data.data;
    if (data == null) {
      emit(const UserProgressFailure("No data returned"));
      return;
    }

    emit(UserProgressSuccess(data: data, selectedVisitNumber: visitNumber));
  }
}
