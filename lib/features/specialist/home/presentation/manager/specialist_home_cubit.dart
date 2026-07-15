import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/home/domain/usecases/get_specialist_home_data_usecase.dart';
import 'specialist_home_state.dart';

class SpecialistHomeCubit extends Cubit<SpecialistHomeState> {
  final GetSpecialistHomeDataUseCase _getSpecialistHomeDataUseCase;

  SpecialistHomeCubit(this._getSpecialistHomeDataUseCase) : super(const SpecialistHomeInitial());

  Future<void> getSpecialistHomeData() async {
    emit(const SpecialistHomeLoading());
    final result = await _getSpecialistHomeDataUseCase();
    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          emit(SpecialistHomeSuccess(data.data!));
        } else {
          emit(const SpecialistHomeFailure('بيانات فارغة'));
        }
      case FailureResult(:final failure):
        emit(SpecialistHomeFailure(failure.message));
    }
  }
}
