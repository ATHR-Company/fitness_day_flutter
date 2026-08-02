import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/features/user/visits/domain/repositories/visits_repository.dart';
import 'package:fitness_day/core/errors/app_error.dart';

part 'assessment_details_state.dart';

class AssessmentDetailsCubit extends Cubit<AssessmentDetailsState> {
  final VisitsRepository _repository;

  AssessmentDetailsCubit(this._repository) : super(AssessmentDetailsInitial()) {
    _progressSub = getIt<AppEventBus>().stream.listen(_applyProgressEvent);
  }

  /// Live patches from the detail screens — see [AppEventBus].
  late final StreamSubscription<AppEvent> _progressSub;

  @override
  Future<void> close() {
    _progressSub.cancel();
    return super.close();
  }

  Map<String, dynamic>? _summaryData;
  Map<String, dynamic>? _dayData;

  Future<void> getInitialData(String assessmentId, int dayNumber) async {
    emit(AssessmentDetailsLoading());
    final summaryResult = await _repository.getAssessmentDetails(assessmentId);
    final dayResult = await _repository.getAssessmentDetails(assessmentId, dayNumber: dayNumber);
    
    if (summaryResult is Success<Map<String, dynamic>>) {
      _summaryData = summaryResult.data;
    }
    if (dayResult is Success<Map<String, dynamic>>) {
      _dayData = dayResult.data;
    }
    
    if (summaryResult is FailureResult<Map<String, dynamic>> || dayResult is FailureResult<Map<String, dynamic>>) {
      final FailureResult<Map<String, dynamic>> failure = summaryResult is FailureResult<Map<String, dynamic>>
          ? summaryResult
          : (dayResult as FailureResult<Map<String, dynamic>>);
      emit(AssessmentDetailsError(failure.failure.message, error: AppError.from(failure.failure)));
    } else {
      emit(AssessmentDetailsLoaded(summaryData: _summaryData, dayData: _dayData));
    }
  }

  /// [silent] keeps the current day on screen instead of dropping to the
  /// spinner, and leaves it there if the refetch fails — used when the refetch
  /// is the cubit's own idea rather than something the user asked for.
  Future<void> getDayDetails(String assessmentId, int dayNumber,
      {bool silent = false}) async {
    if (!silent) emit(AssessmentDetailsLoading());
    final result = await _repository.getAssessmentDetails(assessmentId, dayNumber: dayNumber);
    switch (result) {
      case Success(:final data):
        _dayData = data;
        emit(AssessmentDetailsLoaded(summaryData: _summaryData, dayData: _dayData));
      case FailureResult(:final failure):
        if (!silent) emit(AssessmentDetailsError(failure.message, error: AppError.from(failure)));
    }
  }

  // ─── Live patching ────────────────────────────────────────────────────────

  /// Rewrites the one task a [TaskProgressEvent] names inside the cached day
  /// payload, so the plan tab updates without refetching the day.
  ///
  /// The payload is kept as the raw map the API sent, and the tab rebuilds its
  /// `TaskData` from it on every build — so patching the map is enough, no
  /// parallel parsed copy has to be kept in sync.
  void _applyProgressEvent(AppEvent event) {
    if (event is! TaskProgressEvent) return;
    if (state is! AssessmentDetailsLoaded) return;

    final Map<String, dynamic>? day = _dayData;
    if (day == null) return;

    // The payload comes in two shapes depending on the caller — same handling
    // as the tab that renders it.
    final Map<String, dynamic> inner =
        day['data'] as Map<String, dynamic>? ?? day;
    final List<dynamic>? tasks = inner['tasks'] as List<dynamic>?;
    if (tasks == null) return;

    // This page can show any day of the plan; an event for another one changes
    // nothing on screen.
    if (inner['assessmentId'] != event.assessmentId ||
        inner['dayNumber'] != event.dayNumber) {
      return;
    }

    final List<int> matches = [
      for (int i = 0; i < tasks.length; i++)
        if (_matches(tasks[i], event)) i,
    ];
    if (matches.isEmpty) return;

    // A day can legitimately hold the same activity twice — two walking items
    // with one shared `activityId` and separate progress. The server credits
    // one of them by `activityItemId`, which this payload does not carry, so
    // there is no way to tell from here which card the event belongs to.
    // Guessing would show one item's progress on the other; refetch instead.
    // It is silent, so the page does not flash.
    if (matches.length > 1) {
      getDayDetails(event.assessmentId, event.dayNumber, silent: true);
      return;
    }

    final int index = matches.first;
    final List<dynamic> nextTasks = List<dynamic>.of(tasks);
    nextTasks[index] = _patch(
      Map<String, dynamic>.from(tasks[index] as Map),
      event,
    );

    // Rebuilt rather than mutated: the state object is what BlocBuilder
    // compares, and a map edited in place would leave it pointing at data that
    // silently changed under it.
    final Map<String, dynamic> nextInner = Map<String, dynamic>.from(inner)
      ..['tasks'] = nextTasks;
    _dayData = identical(inner, day)
        ? nextInner
        : (Map<String, dynamic>.from(day)..['data'] = nextInner);

    emit(AssessmentDetailsLoaded(summaryData: _summaryData, dayData: _dayData));
  }

  /// Both the task's kind and its id have to line up — ids are only unique
  /// within a kind.
  bool _matches(dynamic task, TaskProgressEvent event) {
    if (task is! Map) return false;
    return switch (event) {
      MealProgressChanged() =>
        task['type'] == 'meal' && task['mealId'] == event.mealId,
      WorkoutProgressChanged() => task['type'] == 'workout' &&
          task['workoutItemId'] == event.workoutItemId,
      ActivityProgressChanged() =>
        task['type'] == 'activity' && task['activityId'] == event.activityId,
    };
  }

  Map<String, dynamic> _patch(
      Map<String, dynamic> task, TaskProgressEvent event) {
    task['isCompleted'] = event.isCompleted;
    switch (event) {
      case MealProgressChanged():
        break;
      case WorkoutProgressChanged():
        task['completedSets'] = event.completedSets;
        task['totalSets'] = event.totalSets;
      case ActivityProgressChanged():
        task['currentProgress'] = event.currentProgress;
        task['goal'] = event.goal;
    }
    return task;
  }
}
