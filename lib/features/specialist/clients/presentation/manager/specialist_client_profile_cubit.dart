import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/domain/usecases/get_specialist_client_profile_usecase.dart';
import 'specialist_client_profile_state.dart';

class SpecialistClientProfileCubit extends Cubit<SpecialistClientProfileState> {
  final GetSpecialistClientProfileUseCase _getSpecialistClientProfileUseCase;

  SpecialistClientProfileCubit(this._getSpecialistClientProfileUseCase)
      : super(const SpecialistClientProfileInitial());

  Future<void> getSpecialistClientProfile({required String userId}) async {
    emit(const SpecialistClientProfileLoading());
    final result = await _getSpecialistClientProfileUseCase(userId: userId);
    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          emit(SpecialistClientProfileSuccess(data.data!));
        } else {
          emit(const SpecialistClientProfileFailure('بيانات فارغة'));
        }
      case FailureResult(:final failure):
        emit(SpecialistClientProfileFailure(failure.message));
    }
  }
}
