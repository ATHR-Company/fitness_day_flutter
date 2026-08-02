import 'package:equatable/equatable.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/errors/app_error.dart';

abstract class UserTodayTasksState extends Equatable {
  const UserTodayTasksState();

  @override
  List<Object?> get props => [];
}

class UserTodayTasksLoading extends UserTodayTasksState {}

class UserTodayTasksError extends UserTodayTasksState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;
  const UserTodayTasksError(this.message, {this.error});

  @override
  List<Object?> get props => [message, error];
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
