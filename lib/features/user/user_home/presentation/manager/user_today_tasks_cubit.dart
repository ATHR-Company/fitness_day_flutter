import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_today_tasks_state.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

class UserTodayTasksCubit extends Cubit<UserTodayTasksState> {
  UserTodayTasksCubit() : super(UserTodayTasksLoading());

  Future<void> loadTasks({int dayNumber = 1}) async {
    emit(UserTodayTasksLoading());
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.get(
        ApiEndpoints.dailyTasks(dayNumber),
        queryParameters: {'page': 1, 'limit': 9},
      );

      final data = response.data['data'];
      final List tasks = data['tasks'] as List? ?? [];

      final List<TaskData> foodTasks = [];
      final List<TaskData> exerciseTasks = [];
      final List<TaskData> activityTasks = [];

      for (final task in tasks) {
        final String type = task['type'] ?? '';

        if (type == 'meal') {
          foodTasks.add(TaskData(
            imagePath: task['image'] ?? '',
            title: task['categoryName'] ?? '',
            description: task['name'] ?? '',
            time: _formatTime(task['time']),
            extraLabel: '${task['calories'] ?? 0}',
            extraUnit: LocaleKeys.home_home_calories_unit.tr(),
            extraIcon: Icons.local_fire_department,
            done: task['isCompleted'] ?? false,
          ));
        } else if (type == 'workout') {
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
    final int currentProgress = (task['currentProgress'] ?? 0).toInt();
    final int goal = (task['goal'] ?? 0).toInt();
    final bool done = task['isCompleted'] ?? false;
    final String unit = task['unit'] ?? '';
    final String name = task['name'] ?? '';
    final String description = task['description'] ?? '';
    final String image = task['image'] ?? '';

    // استخدام السيرفر image مباشرة — التحقق من امتداد svg
    final bool isSvg = image.toLowerCase().endsWith('.svg');

    return TaskData(
      imagePath: image,
      isSvgImage: isSvg,
      title: name,
      time: LocaleKeys.home_hydration_all_day.tr(),
      description: description,
      extraLabel: '$currentProgress / $goal',
      extraUnit: unit,
      extraIcon: null,
      done: done,
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
