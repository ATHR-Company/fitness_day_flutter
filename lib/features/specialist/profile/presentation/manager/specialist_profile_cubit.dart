import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/profile/data/models/specialist_profile_model.dart';
import 'package:fitness_day/features/specialist/profile/domain/usecases/get_specialist_profile_usecase.dart';
import 'package:fitness_day/features/specialist/profile/domain/usecases/update_specialist_profile_usecase.dart';
import 'specialist_profile_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class SpecialistProfileCubit extends Cubit<SpecialistProfileState> {
  final GetSpecialistProfileUseCase _getSpecialistProfileUseCase;
  final UpdateSpecialistProfileUseCase _updateSpecialistProfileUseCase;

  SpecialistProfileDataModel? profileData;

  SpecialistProfileCubit(
    this._getSpecialistProfileUseCase,
    this._updateSpecialistProfileUseCase,
  ) : super(const SpecialistProfileInitial());

  Future<void> getSpecialistProfile() async {
    emit(const SpecialistProfileLoading());
    final result = await _getSpecialistProfileUseCase();
    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          profileData = data.data;
          emit(SpecialistProfileSuccess(profileData!));
        } else {
          emit(const SpecialistProfileFailure('بيانات فارغة'));
        }
      case FailureResult(:final failure):
        emit(SpecialistProfileFailure(failure.message, error: AppError.from(failure)));
    }
  }

  Future<void> updateSpecialistProfile({
    required String name,
    String? avatarPath,
  }) async {
    emit(const SpecialistProfileUpdating());
    final result = await _updateSpecialistProfileUseCase(
      name: name,
      avatarPath: avatarPath,
    );
    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          profileData = data.data;
        } else {
          profileData = SpecialistProfileDataModel(
            id: profileData?.id ?? '',
            name: name,
            avatar: profileData?.avatar ?? '',
          );
        }
        emit(SpecialistProfileSuccess(profileData!));
      case FailureResult(:final failure):
        emit(SpecialistProfileUpdateFailure(failure.message, error: AppError.from(failure)));
    }
  }
}
