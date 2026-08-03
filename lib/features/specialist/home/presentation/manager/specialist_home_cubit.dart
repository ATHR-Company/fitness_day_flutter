import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/home/domain/usecases/get_specialist_home_data_usecase.dart';
import 'specialist_home_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/network/connectivity_service.dart';

class SpecialistHomeCubit extends Cubit<SpecialistHomeState> {
  final GetSpecialistHomeDataUseCase _getSpecialistHomeDataUseCase;
  StreamSubscription<bool>? _connectivitySub;

  SpecialistHomeCubit(this._getSpecialistHomeDataUseCase) : super(const SpecialistHomeInitial()) {
    _connectivitySub = ConnectivityService().onStatusChange.listen((online) {
      if (!online) {
        emit(SpecialistHomeFailure(
          'errors.no_internet_title'.tr(),
          error: const AppError(type: AppErrorType.network, message: ''),
        ));
      } else {
        if (state is SpecialistHomeFailure) {
          getSpecialistHomeData();
        }
      }
    });
  }

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
        emit(SpecialistHomeFailure(failure.message, error: AppError.from(failure)));
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
