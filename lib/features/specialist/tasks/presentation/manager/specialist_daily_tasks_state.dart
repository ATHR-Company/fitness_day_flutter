import 'package:fitness_day/features/specialist/tasks/data/models/specialist_daily_task_model.dart';

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

  const SpecialistDailyTasksFailure(this.message);
}

class SpecialistDailyTasksLoadingMore extends SpecialistDailyTasksState {
  final List<SpecialistDailyTaskItemModel> tasks;

  const SpecialistDailyTasksLoadingMore(this.tasks);
}
