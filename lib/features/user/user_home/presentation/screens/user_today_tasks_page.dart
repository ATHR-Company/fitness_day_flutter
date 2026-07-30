import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_today_tasks_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/today_tasks/user_today_tasks_content.dart';

class UserTodayTasksPage extends StatelessWidget {
  const UserTodayTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserTodayTasksCubit()..loadTasks(dayNumber: 1),
      child: const UserTodayTasksContent(),
    );
  }
}
