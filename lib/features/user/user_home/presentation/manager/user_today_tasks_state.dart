import 'package:equatable/equatable.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';

abstract class UserTodayTasksState extends Equatable {
  const UserTodayTasksState();

  @override
  List<Object?> get props => [];
}

class UserTodayTasksLoading extends UserTodayTasksState {}

class UserTodayTasksLoaded extends UserTodayTasksState {
  final List<TaskData> foodTasks;
  final List<TaskData> exerciseTasks;

  const UserTodayTasksLoaded({
    required this.foodTasks,
    required this.exerciseTasks,
  });

  @override
  List<Object?> get props => [foodTasks, exerciseTasks];
}
