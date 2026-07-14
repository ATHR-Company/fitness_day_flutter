import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/profile/domain/usecases/get_specialist_profile_usecase.dart';
import 'specialist_profile_state.dart';

class SpecialistProfileCubit extends Cubit<SpecialistProfileState> {
  final GetSpecialistProfileUseCase _getSpecialistProfileUseCase;

  SpecialistProfileCubit(this._getSpecialistProfileUseCase) : super(const SpecialistProfileInitial());

  Future<void> getSpecialistProfile() async {
    emit(const SpecialistProfileLoading());
    final result = await _getSpecialistProfileUseCase();
    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          emit(SpecialistProfileSuccess(data.data!));
        } else {
          emit(const SpecialistProfileFailure('بيانات فارغة'));
        }
      case FailureResult(:final failure):
        emit(SpecialistProfileFailure(failure.message));
    }
  }
}
