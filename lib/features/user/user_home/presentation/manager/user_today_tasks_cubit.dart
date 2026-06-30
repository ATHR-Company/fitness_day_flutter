import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_today_tasks_state.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

class UserTodayTasksCubit extends Cubit<UserTodayTasksState> {
  UserTodayTasksCubit() : super(UserTodayTasksLoading());

  void loadTasks() {
    final foodTasks = [
      TaskData(
        imagePath: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=200',
        title: LocaleKeys.home_home_task_1_title.tr(),
        description: LocaleKeys.home_home_task_1_desc.tr(),
        time: LocaleKeys.home_home_task_1_time.tr(),
        extraLabel: '350',
        extraUnit: LocaleKeys.home_home_calories_unit.tr(),
        extraIcon: Icons.local_fire_department,
        done: true,
        route: UserAppRoutes.mealDetails,
      ),
      TaskData(
        imagePath: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200',
        title: LocaleKeys.add_meal_lunch.tr(),
        description: '150 ${LocaleKeys.clients_page_gram.tr()}...',
        time: '3:00',
        extraLabel: '350',
        extraUnit: LocaleKeys.home_home_calories_unit.tr(),
        extraIcon: Icons.local_fire_department,
        done: false,
        route: UserAppRoutes.mealDetails,
      ),
    ];

    final exerciseTasks = [
      TaskData(
        imagePath: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200',
        title: LocaleKeys.home_home_task_2_title.tr(),
        description: LocaleKeys.home_home_task_2_desc.tr(),
        time: LocaleKeys.home_home_task_2_time.tr(),
        extraLabel: '3',
        extraUnit: '3',
        extraIcon: null,
        done: true,
        isExerciseDialog: true,
      ),
    ];

    emit(UserTodayTasksLoaded(
      foodTasks: foodTasks,
      exerciseTasks: exerciseTasks,
    ));
  }
}
