import 'package:fitness_day/core/errors/app_error.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/programs/data/models/specialist_program_model.dart';
import 'package:fitness_day/features/specialist/programs/domain/usecases/get_program_weeks_usecase.dart';
import 'package:fitness_day/features/specialist/programs/domain/usecases/get_specialist_programs_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'programs_state.dart';

/// Drives the two-step picker: programs, then the weeks of the one that was
/// tapped.
///
/// Applying is **not** here. That writes to a visit, so it goes through
/// `VisitDetailsCubit`, which owns the visit's plan cache and has to rebuild
/// it afterwards — the same split the add-meal / add-exercise screens already
/// use for their lookups.
class ProgramsCubit extends Cubit<ProgramsState> {
  final GetSpecialistProgramsUseCase _getProgramsUseCase;
  final GetProgramWeeksUseCase _getProgramWeeksUseCase;

  ProgramsCubit(this._getProgramsUseCase, this._getProgramWeeksUseCase)
      : super(const ProgramsInitial());

  static const int _pageSize = 50;

  Future<void> loadPrograms({String? search}) async {
    final currentState = state;

    /*
      Only the very first load takes the screen to `ProgramsLoading`. A search
      keeps the loaded state and flips `isSearching` instead: dropping to a
      spinner would rebuild the list into a different widget tree and unmount
      the search field the specialist is still typing in.
    */
    if (currentState is ProgramsLoaded) {
      emit(currentState.copyWith(isSearching: true));
    } else {
      emit(const ProgramsLoading());
    }

    final result = await _getProgramsUseCase(
      page: 1,
      limit: _pageSize,
      search: search,
    );

    switch (result) {
      case Success(:final data):
        emit(ProgramsLoaded(programs: data.data));
      case FailureResult(:final failure):
        emit(ProgramsFailure(failure.message, error: AppError.from(failure)));
    }
  }

  Future<void> selectProgram(SpecialistProgramModel program) async {
    final currentState = state;
    if (currentState is! ProgramsLoaded) return;

    emit(currentState.copyWith(
      selectedProgram: program,
      weeks: const [],
      isLoadingWeeks: true,
    ));

    final result = await _getProgramWeeksUseCase(programId: program.id);

    switch (result) {
      case Success(:final data):
        emit(currentState.copyWith(
          selectedProgram: program,
          weeks: data.data?.weeks ?? const [],
          isLoadingWeeks: false,
        ));
      case FailureResult(:final failure):
        // The failure screen, not an empty week sheet — there is nothing
        // useful to do on a program whose weeks wouldn't load, and its retry
        // reloads the program list.
        emit(ProgramsFailure(failure.message, error: AppError.from(failure)));
    }
  }

  /// Back to the program list from the week step.
  void clearSelection() {
    final currentState = state;
    if (currentState is ProgramsLoaded) {
      emit(currentState.copyWith(clearSelection: true));
    }
  }
}
