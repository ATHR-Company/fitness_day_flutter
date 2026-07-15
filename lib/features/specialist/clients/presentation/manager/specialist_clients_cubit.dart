import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/domain/usecases/get_specialist_clients_usecase.dart';
import 'specialist_clients_state.dart';

class SpecialistClientsCubit extends Cubit<SpecialistClientsState> {
  final GetSpecialistClientsUseCase _getSpecialistClientsUseCase;

  SpecialistClientsCubit(this._getSpecialistClientsUseCase) : super(const SpecialistClientsInitial());

  Future<void> getSpecialistClients({
    int page = 1,
    int limit = 5,
    required String status,
    String? search,
  }) async {
    emit(const SpecialistClientsLoading());
    final result = await _getSpecialistClientsUseCase(
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
    switch (result) {
      case Success(:final data):
        emit(SpecialistClientsSuccess(data));
      case FailureResult(:final failure):
        emit(SpecialistClientsFailure(failure.message));
    }
  }
}
