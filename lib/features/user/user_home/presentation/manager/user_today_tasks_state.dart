import 'package:equatable/equatable.dart';
import 'package:fitness_day/core/entities/task_data.dart';

abstract class UserTodayTasksState extends Equatable {
  const UserTodayTasksState();

  @override
  List<Object?> get props => [];
}

class UserTodayTasksLoading extends UserTodayTasksState {}

class UserTodayTasksError extends UserTodayTasksState {
  final String message;
  const UserTodayTasksError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserTodayTasksLoaded extends UserTodayTasksState {
  final List<TaskData> foodTasks;
  final List<TaskData> exerciseTasks;
  final List<TaskData> activityTasks;

  const UserTodayTasksLoaded({
    required this.foodTasks,
    required this.exerciseTasks,
    required this.activityTasks,
  });

  @override
  List<Object?> get props => [foodTasks, exerciseTasks, activityTasks];
}
