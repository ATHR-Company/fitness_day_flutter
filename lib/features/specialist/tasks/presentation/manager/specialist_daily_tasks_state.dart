import 'package:fitness_day/features/specialist/tasks/data/models/specialist_daily_task_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class SpecialistDailyTasksState {
  const SpecialistDailyTasksState();
}

class SpecialistDailyTasksInitial extends SpecialistDailyTasksState {
  const SpecialistDailyTasksInitial();
}

class SpecialistDailyTasksLoading extends SpecialistDailyTasksState {
  const SpecialistDailyTasksLoading();
}

class SpecialistDailyTasksSuccess extends SpecialistDailyTasksState {
  final List<SpecialistDailyTaskItemModel> tasks;
  final bool hasReachedMax;

  const SpecialistDailyTasksSuccess({
    required this.tasks,
    required this.hasReachedMax,
  });
}

class SpecialistDailyTasksFailure extends SpecialistDailyTasksState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const SpecialistDailyTasksFailure(this.message, {this.error});
}

class SpecialistDailyTasksLoadingMore extends SpecialistDailyTasksState {
  final List<SpecialistDailyTaskItemModel> tasks;

  const SpecialistDailyTasksLoadingMore(this.tasks);
}
