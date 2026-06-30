import 'package:equatable/equatable.dart';

abstract class UserTodayTasksState extends Equatable {
  const UserTodayTasksState();

  @override
  List<Object?> get props => [];
}

class UserTodayTasksLoading extends UserTodayTasksState {}

class UserTodayTasksLoaded extends UserTodayTasksState {
  final List<dynamic> foodTasks;
  final List<dynamic> exerciseTasks;

  const UserTodayTasksLoaded({
    required this.foodTasks,
    required this.exerciseTasks,
  });

  @override
  List<Object?> get props => [foodTasks, exerciseTasks];
}
