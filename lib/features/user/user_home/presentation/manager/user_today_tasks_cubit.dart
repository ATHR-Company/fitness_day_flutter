import 'dart:async';

import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_today_tasks_state.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

class UserTodayTasksCubit extends Cubit<UserTodayTasksState> {
  UserTodayTasksCubit() : super(UserTodayTasksLoading()) {
    _progressSub = getIt<AppEventBus>().stream.listen(_applyProgressEvent);
  }

  /// Live patches from the detail screens — see [AppEventBus].
  late final StreamSubscription<AppEvent> _progressSub;

  @override
  Future<void> close() {
    _progressSub.cancel();
    return super.close();
  }

  String _assessmentId = '';
  int _dayNumber = 1;

  /// [silent] keeps the current list on screen instead of dropping to the
  /// spinner — used when the cubit refetches on its own initiative.
  Future<void> loadTasks({int dayNumber = 1, bool silent = false}) async {
    _dayNumber = dayNumber;
    if (!silent) emit(UserTodayTasksLoading());
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.get(
        ApiEndpoints.dailyTasks(dayNumber),
        queryParameters: {'page': 1, 'limit': 9},
      );

      final data = response.data['data'];
      final List tasks = data['tasks'] as List? ?? [];
      final String assessmentIdFromApi = data['assessmentId'] as String? ?? '';
      // Fallback to cached assessmentId (saved by UserHomeCubit) if API didn't return one
      final String assessmentId = assessmentIdFromApi.isNotEmpty
          ? assessmentIdFromApi
          : (getIt<AppCache>().getAssessmentId() ?? '');
      _assessmentId = assessmentId;

      final List<TaskData> foodTasks = [];
      final List<TaskData> exerciseTasks = [];
      final List<TaskData> activityTasks = [];

      for (final task in tasks) {
        final String type = task['type'] ?? '';

        if (type == 'meal') {
          final String mealId = task['mealId'] as String? ?? '';
          foodTasks.add(TaskData(
            taskId: mealId,
            imagePath: task['image'] ?? '',
            title: task['categoryName'] ?? '',
            description: task['name'] ?? '',
            time: _formatTime(task['time']),
            extraLabel: '${task['calories'] ?? 0}',
            extraUnit: LocaleKeys.home_home_calories_unit.tr(),
            extraIcon: Icons.local_fire_department,
            done: task['isCompleted'] ?? false,
            route: UserAppRoutes.mealDetails,
            routeExtra: {
              'mealId': mealId,
              'assessmentId': assessmentId,
              'dayNumber': dayNumber,
            },
          ));
        } else if (type == 'workout') {
          final String workoutItemId = task['workoutItemId'] as String? ?? '';
          exerciseTasks.add(TaskData(
            taskId: workoutItemId,
            imagePath: task['photo'] ?? '',
            title: task['name'] ?? '',
            description: task['description'] ?? '',
            time: _formatTime(task['time']),
            extraLabel: '${task['completedSets'] ?? 0}',
            extraUnit: '${task['totalSets'] ?? 0}',
            extraIcon: null,
            done: task['isCompleted'] ?? false,
            isExerciseDialog: true,
            workoutItemId: workoutItemId,
            workoutDayNumber: dayNumber,
            workoutAssessmentId: assessmentId,
          ));
        } else if (type == 'activity') {
          activityTasks.add(_buildActivityTask(task));
        }
      }

      emit(UserTodayTasksLoaded(
        foodTasks: foodTasks,
        exerciseTasks: exerciseTasks,
        activityTasks: activityTasks,
      ));
    } catch (e) {
      // A silent refetch must not replace a good list with an error screen.
      if (!silent) emit(UserTodayTasksError('فشل تحميل المهام. حاول مرة أخرى.'));
    }
  }

  TaskData _buildActivityTask(Map<String, dynamic> task) {
    final String activityType = task['activityType'] ?? '';
    final String activityId = task['activityId'] as String? ?? '';
    final double currentProgress = (task['currentProgress'] ?? 0).toDouble();
    final double goal = (task['goal'] ?? 0).toDouble();
    final bool done = task['isCompleted'] ?? false;
    final String unit = task['unit'] ?? '';
    final String name = task['name'] ?? '';
    final String description = task['description'] ?? '';
    final String image = task['image'] ?? '';
    final bool isSvg = image.toLowerCase().endsWith('.svg');

    // Pick an icon based on activity type
    IconData activityIcon;
    switch (activityType) {
      case 'hydration':
        activityIcon = Icons.water_drop_outlined;
        break;
      case 'walking':
        activityIcon = Icons.directions_walk;
        break;
      case 'running':
        activityIcon = Icons.directions_run;
        break;
      default:
        activityIcon = Icons.local_activity_outlined;
    }

    return TaskData(
      taskId: activityId,
      imagePath: image,
      isSvgImage: isSvg,
      title: name,
      time: LocaleKeys.home_hydration_all_day.tr(),
      description: description,
      extraLabel: _progressLabel(currentProgress),
      extraUnit: '/ $goal $unit',
      extraIcon: activityIcon,
      done: done,
      // Store IDs so _buildActivityCallback can read them.
      // `unit` rides along too: a live progress patch has to rebuild the
      // "/ goal unit" caption, and the unit is not recoverable from TaskData.
      routeExtra: {
        'activityId': activityId,
        'activityType': activityType,
        'assessmentId': _assessmentId,
        'dayNumber': _dayNumber,
        'unit': unit,
      },
    );
  }

  /// Whole numbers render bare; fractional hydration keeps two decimals.
  static String _progressLabel(double value) => value % 1 == 0
      ? value.toInt().toString()
      : value.toStringAsFixed(2);

  // ─── Live patching ────────────────────────────────────────────────────────

  /// Updates the one card an event names, without refetching the day.
  ///
  /// The event may arrive while this screen sits *under* a detail screen the
  /// user pushed from it, or under the home screen — both cases are the same
  /// here, because nothing about the patch depends on who is on top.
  void _applyProgressEvent(AppEvent event) {
    if (event is! TaskProgressEvent) return;

    final UserTodayTasksState current = state;
    if (current is! UserTodayTasksLoaded) return;

    // The user can be browsing any day of the plan; only the day currently
    // rendered is affected by the change.
    if (event.assessmentId != _assessmentId || event.dayNumber != _dayNumber) {
      return;
    }

    switch (event) {
      case MealProgressChanged():
        final patched = _patchTask(
          current.foodTasks,
          event.taskId,
          (task) => task.copyWith(done: event.isCompleted),
        );
        if (identical(patched, current.foodTasks)) return;
        emit(UserTodayTasksLoaded(
          foodTasks: patched,
          exerciseTasks: current.exerciseTasks,
          activityTasks: current.activityTasks,
        ));

      case WorkoutProgressChanged():
        final patched = _patchTask(
          current.exerciseTasks,
          event.taskId,
          (task) => task.copyWith(
            done: event.isCompleted,
            extraLabel: '${event.completedSets}',
            extraUnit: '${event.totalSets}',
          ),
        );
        if (identical(patched, current.exerciseTasks)) return;
        emit(UserTodayTasksLoaded(
          foodTasks: current.foodTasks,
          exerciseTasks: patched,
          activityTasks: current.activityTasks,
        ));

      case ActivityProgressChanged():
        final patched = _patchTask(
          current.activityTasks,
          event.taskId,
          (task) {
            final extra = task.routeExtra;
            final String unit =
                extra is Map ? (extra['unit'] as String? ?? '') : '';
            return task.copyWith(
              done: event.isCompleted,
              extraLabel: _progressLabel(event.currentProgress),
              extraUnit: '/ ${event.goal} $unit',
            );
          },
        );
        if (identical(patched, current.activityTasks)) return;
        emit(UserTodayTasksLoaded(
          foodTasks: current.foodTasks,
          exerciseTasks: current.exerciseTasks,
          activityTasks: patched,
        ));
    }
  }

  /// Returns the same list instance when nothing matched, so the caller can skip
  /// the emit entirely rather than rebuilding the page for an unrelated event.
  ///
  /// When *several* cards carry the id the patch is refused and the day is
  /// refetched instead: a day can hold the same activity twice — two walking
  /// items sharing one `activityId`, each with its own progress — and the
  /// server credits one of them by `activityItemId`, which this payload does
  /// not carry. Patching the first match would show one item's figure on the
  /// other.
  List<TaskData> _patchTask(
    List<TaskData> tasks,
    String taskId,
    TaskData Function(TaskData) patch,
  ) {
    if (taskId.isEmpty) return tasks;
    final List<int> matches = [
      for (int i = 0; i < tasks.length; i++)
        if (tasks[i].taskId == taskId) i,
    ];
    if (matches.isEmpty) return tasks;
    if (matches.length > 1) {
      loadTasks(dayNumber: _dayNumber, silent: true);
      return tasks;
    }
    final List<TaskData> next = List<TaskData>.of(tasks);
    next[matches.first] = patch(next[matches.first]);
    return next;
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null || isoTime.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (_) {
      return '';
    }
  }
}
