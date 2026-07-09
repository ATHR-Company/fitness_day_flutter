import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/visits/domain/usecases/get_diet_plan_usecase.dart';
import 'diet_plan_state.dart';

class DietPlanCubit extends Cubit<DietPlanState> {
  final GetDietPlanUseCase _getDietPlanUseCase;

  DietPlanCubit({
    required GetDietPlanUseCase getDietPlanUseCase,
  })  : _getDietPlanUseCase = getDietPlanUseCase,
        super(const DietPlanInitial());

  Future<void> getDietPlan(int day) async {
    emit(const DietPlanLoading());
    final result = await _getDietPlanUseCase(day);
    switch (result) {
      case Success(:final data):
        emit(DietPlanSuccess(data.data));
      case FailureResult(:final failure):
        emit(DietPlanFailure(failure.message));
    }
  }
}
