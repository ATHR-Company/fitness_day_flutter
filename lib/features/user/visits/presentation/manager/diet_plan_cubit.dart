import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:fitness_day/features/user/visits/domain/usecases/get_diet_plan_usecase.dart';
import 'diet_plan_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class DietPlanCubit extends Cubit<DietPlanState> {
  final GetDietPlanUseCase _getDietPlanUseCase;

  /// Live patches from the meal details screen — see [AppEventBus].
  late final StreamSubscription<AppEvent> _progressSub;

  DietPlanCubit({
    required GetDietPlanUseCase getDietPlanUseCase,
  })  : _getDietPlanUseCase = getDietPlanUseCase,
        super(const DietPlanInitial()) {
    _progressSub = getIt<AppEventBus>().stream.listen(_applyProgressEvent);
  }

  @override
  Future<void> close() {
    _progressSub.cancel();
    return super.close();
  }

  Future<void> getDietPlan(int day) async {
    emit(const DietPlanLoading());
    final result = await _getDietPlanUseCase(day);
    switch (result) {
      case Success(:final data):
        emit(DietPlanSuccess(data.data));
      case FailureResult(:final failure):
        emit(DietPlanFailure(failure.message, error: AppError.from(failure)));
    }
  }

  /// Ticks the one meal the user just completed, without refetching the day.
  ///
  /// Only meal events matter here — the diet plan lists nothing else.
  void _applyProgressEvent(AppEvent event) {
    if (event is! MealProgressChanged) return;

    final DietPlanState current = state;
    if (current is! DietPlanSuccess) return;

    final DietPlanData? plan = current.dietPlanData;
    if (plan == null) return;

    // The page can be showing any day of the plan.
    if (plan.assessmentId != event.assessmentId ||
        plan.dayNumber != event.dayNumber) {
      return;
    }

    final int index = plan.meals.indexWhere((m) => m.id == event.mealId);
    if (index == -1) return;

    final List<MealItem> meals = List<MealItem>.of(plan.meals);
    meals[index] = meals[index].copyWith(isCompleted: event.isCompleted);
    emit(DietPlanSuccess(plan.copyWith(meals: meals)));
  }
}
