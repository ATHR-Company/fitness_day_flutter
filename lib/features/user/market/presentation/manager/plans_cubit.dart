import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/market/domain/entities/plans_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_plans_usecase.dart';

sealed class PlansState {
  const PlansState();
}

class PlansInitial extends PlansState {
  const PlansInitial();
}

class PlansLoading extends PlansState {
  const PlansLoading();
}

class PlansSuccess extends PlansState {
  final PlansData data;

  const PlansSuccess(this.data);
}

class PlansFailure extends PlansState {
  final String message;

  const PlansFailure(this.message);
}

class PlansCubit extends Cubit<PlansState> {
  final GetPlansUseCase _getPlansUseCase;

  PlansCubit(this._getPlansUseCase) : super(const PlansInitial());

  Future<void> load() async {
    emit(const PlansLoading());
    final result = await _getPlansUseCase();
    if (result is Success<PlansData>) {
      emit(PlansSuccess(result.data));
    } else if (result is FailureResult<PlansData>) {
      emit(PlansFailure(result.failure.message));
    }
  }
}
