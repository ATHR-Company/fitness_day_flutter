import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/market/domain/entities/plans_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_plan_by_id_usecase.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class PlanDetailsState {
  const PlanDetailsState();
}

class PlanDetailsInitial extends PlanDetailsState {
  const PlanDetailsInitial();
}

class PlanDetailsLoading extends PlanDetailsState {
  const PlanDetailsLoading();
}

class PlanDetailsSuccess extends PlanDetailsState {
  final PlanDetails details;
  final int selectedPhotoIndex;

  const PlanDetailsSuccess({
    required this.details,
    this.selectedPhotoIndex = 0,
  });

  PlanDetailsSuccess copyWith({PlanDetails? details, int? selectedPhotoIndex}) {
    return PlanDetailsSuccess(
      details: details ?? this.details,
      selectedPhotoIndex: selectedPhotoIndex ?? this.selectedPhotoIndex,
    );
  }
}

class PlanDetailsFailure extends PlanDetailsState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const PlanDetailsFailure(this.message, {this.error});
}

class PlanDetailsCubit extends Cubit<PlanDetailsState> {
  final GetPlanByIdUseCase _getPlanByIdUseCase;

  PlanDetailsCubit(this._getPlanByIdUseCase) : super(const PlanDetailsInitial());

  Future<void> load(String id) async {
    emit(const PlanDetailsLoading());
    final result = await _getPlanByIdUseCase(id);
    if (result is Success<PlanDetails>) {
      emit(PlanDetailsSuccess(details: result.data));
    } else if (result is FailureResult<PlanDetails>) {
      emit(PlanDetailsFailure(result.failure.message, error: AppError.from(result.failure)));
    }
  }

  void selectPhoto(int index) {
    final current = state;
    if (current is PlanDetailsSuccess) {
      emit(current.copyWith(selectedPhotoIndex: index));
    }
  }
}
