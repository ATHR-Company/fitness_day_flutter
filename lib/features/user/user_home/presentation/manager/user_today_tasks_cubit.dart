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
import 'package:fitness_day/features/user/user_home/presentation/manager/user_today_tasks_state.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

class UserTodayTasksCubit extends Cubit<UserTodayTasksState> {
  UserTodayTasksCubit() : super(UserTodayTasksLoading());

  String _assessmentId = '';
  int _dayNumber = 1;

  Future<void> loadTasks({int dayNumber = 1}) async {
    _dayNumber = dayNumber;
    emit(UserTodayTasksLoading());
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
      emit(UserTodayTasksError('فشل تحميل المهام. حاول مرة أخرى.'));
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
      imagePath: image,
      isSvgImage: isSvg,
      title: name,
      time: LocaleKeys.home_hydration_all_day.tr(),
      description: description,
      extraLabel: currentProgress % 1 == 0
          ? currentProgress.toInt().toString()
          : currentProgress.toStringAsFixed(2),
      extraUnit: '/ $goal $unit',
      extraIcon: activityIcon,
      done: done,
      // Store IDs so _buildActivityCallback can read them
      routeExtra: {
        'activityId': activityId,
        'activityType': activityType,
        'assessmentId': _assessmentId,
        'dayNumber': _dayNumber,
      },
    );
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
