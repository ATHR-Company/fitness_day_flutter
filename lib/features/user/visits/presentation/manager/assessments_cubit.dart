import 'package:equatable/equatable.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fitness_day/features/user/visits/data/models/assessment_model.dart';
import 'package:fitness_day/features/user/visits/domain/repositories/visits_repository.dart';
import 'package:fitness_day/core/errors/app_error.dart';

part 'assessments_state.dart';

class AssessmentsCubit extends Cubit<AssessmentsState> {
  final VisitsRepository _visitsRepository;

  AssessmentsCubit(this._visitsRepository) : super(AssessmentsInitial());

  DateTime _currentWeekStart = DateTime.now();
  DateTime? _firstWeekStart;
  DateTime? _lastWeekStart;

  /// Normalises any date to the Sunday that starts its week, dropping the time
  /// and timezone. Both bounds and [_currentWeekStart] must be compared as
  /// aligned week-starts — the API returns `lastDateOfWeekStart` as a raw date
  /// that can fall mid-week (e.g. 2026-07-23 inside the 2026-07-19 week), so
  /// comparing the week-start against it directly let "next" stay enabled even
  /// though the last week with data is the one already on screen.
  DateTime _weekStartOf(DateTime date) {
    final DateTime local = date.toLocal();
    final DateTime dayOnly = DateTime(local.year, local.month, local.day);
    return dayOnly.subtract(Duration(days: dayOnly.weekday % 7));
  }

  bool get canGoPrevious =>
      _firstWeekStart != null &&
      _currentWeekStart.isAfter(_weekStartOf(_firstWeekStart!));

  bool get canGoNext =>
      _lastWeekStart != null &&
      _currentWeekStart.isBefore(_weekStartOf(_lastWeekStart!));

  void fetchAssessmentsForCurrentWeek() {
    _currentWeekStart = _weekStartOf(DateTime.now());
    _fetchAssessments(_currentWeekStart);
  }

  void nextWeek() {
    if (!canGoNext) return;
    _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    _fetchAssessments(_currentWeekStart);
  }

  void previousWeek() {
    if (!canGoPrevious) return;
    _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    _fetchAssessments(_currentWeekStart);
  }

  Future<void> _fetchAssessments(DateTime weekStart) async {
    emit(AssessmentsLoading());
    // Use 'en_US' locale explicitly so API always receives ASCII digits (2026-07-12)
    // not Arabic-Indic digits (٢٠٢٦-٠٧-١٢) which happen when device is set to Arabic
    final DateFormat formatter = DateFormat('yyyy-MM-dd', 'en_US');
    final String weekStartStr = formatter.format(weekStart);
    final String weekEndStr = formatter.format(weekStart.add(const Duration(days: 6)));

    final result = await _visitsRepository.getAssessments(weekStartStr, weekEndStr);
    
    if (result is Success<AssessmentsResponse>) {
      _firstWeekStart = result.data.firstDateOfWeekStart;
      _lastWeekStart = result.data.lastDateOfWeekStart;
      emit(AssessmentsLoaded(response: result.data, currentWeekStart: weekStart));
    } else if (result is FailureResult<AssessmentsResponse>) {
      emit(AssessmentsError(message: result.failure.message, error: AppError.from(result.failure)));
    }
  }
}
