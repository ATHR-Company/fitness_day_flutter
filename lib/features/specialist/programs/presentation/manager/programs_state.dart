import 'package:fitness_day/core/errors/app_error.dart';
import 'package:fitness_day/features/specialist/programs/data/models/specialist_program_model.dart';

sealed class ProgramsState {
  const ProgramsState();
}

class ProgramsInitial extends ProgramsState {
  const ProgramsInitial();
}

class ProgramsLoading extends ProgramsState {
  const ProgramsLoading();
}

class ProgramsFailure extends ProgramsState {
  final String message;
  final AppError? error;

  const ProgramsFailure(this.message, {this.error});
}

/// The picker's one loaded state.
///
/// [weeks] is filled only after a program is opened — the list endpoint
/// doesn't carry them, and loading every program's weeks up front would be a
/// request per row for something the specialist opens one of.
class ProgramsLoaded extends ProgramsState {
  final List<SpecialistProgramModel> programs;
  final SpecialistProgramModel? selectedProgram;
  final List<SpecialistProgramWeekModel> weeks;
  final bool isLoadingWeeks;

  /// A search is in flight. Kept on the loaded state rather than emitting
  /// `ProgramsLoading`, because that would unmount the search field mid-typing
  /// and take the caret and the text with it.
  final bool isSearching;

  const ProgramsLoaded({
    required this.programs,
    this.selectedProgram,
    this.weeks = const [],
    this.isLoadingWeeks = false,
    this.isSearching = false,
  });

  ProgramsLoaded copyWith({
    List<SpecialistProgramModel>? programs,
    SpecialistProgramModel? selectedProgram,
    List<SpecialistProgramWeekModel>? weeks,
    bool? isLoadingWeeks,
    bool? isSearching,
    bool clearSelection = false,
  }) {
    return ProgramsLoaded(
      programs: programs ?? this.programs,
      // `copyWith(selectedProgram: null)` can't express "go back to the list",
      // because null already means "leave it alone" — hence the explicit flag.
      selectedProgram:
          clearSelection ? null : (selectedProgram ?? this.selectedProgram),
      weeks: clearSelection ? const [] : (weeks ?? this.weeks),
      isLoadingWeeks: isLoadingWeeks ?? this.isLoadingWeeks,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}
