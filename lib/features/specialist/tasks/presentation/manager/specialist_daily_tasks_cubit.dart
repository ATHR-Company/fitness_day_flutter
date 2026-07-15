import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/tasks/data/models/specialist_daily_task_model.dart';
import 'package:fitness_day/features/specialist/tasks/domain/usecases/get_specialist_daily_tasks_usecase.dart';
import 'specialist_daily_tasks_state.dart';

class SpecialistDailyTasksCubit extends Cubit<SpecialistDailyTasksState> {
  final GetSpecialistDailyTasksUseCase _getSpecialistDailyTasksUseCase;

  int _currentPage = 1;
  static const int _limit = 10;
  final List<SpecialistDailyTaskItemModel> _allTasks = [];
  bool _hasReachedMax = false;

  SpecialistDailyTasksCubit(this._getSpecialistDailyTasksUseCase)
      : super(const SpecialistDailyTasksInitial());

  Future<void> getDailyTasks({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _allTasks.clear();
      _hasReachedMax = false;
    }

    emit(const SpecialistDailyTasksLoading());

    final result = await _getSpecialistDailyTasksUseCase(page: _currentPage, limit: _limit);

    switch (result) {
      case Success(:final data):
        _allTasks.addAll(data.data);
        _hasReachedMax = _allTasks.length >= data.totalCount || data.data.isEmpty;
        emit(SpecialistDailyTasksSuccess(
          tasks: List.from(_allTasks),
          hasReachedMax: _hasReachedMax,
        ));
      case FailureResult(:final failure):
        emit(SpecialistDailyTasksFailure(failure.message));
    }
  }

  Future<void> loadMoreDailyTasks() async {
    if (state is SpecialistDailyTasksLoading ||
        state is SpecialistDailyTasksLoadingMore ||
        _hasReachedMax) {
      return;
    }

    emit(SpecialistDailyTasksLoadingMore(List.from(_allTasks)));

    _currentPage++;

    final result = await _getSpecialistDailyTasksUseCase(page: _currentPage, limit: _limit);

    switch (result) {
      case Success(:final data):
        if (data.data.isEmpty) {
          _hasReachedMax = true;
        } else {
          _allTasks.addAll(data.data);
          _hasReachedMax = _allTasks.length >= data.totalCount;
        }
        emit(SpecialistDailyTasksSuccess(
          tasks: List.from(_allTasks),
          hasReachedMax: _hasReachedMax,
        ));
      case FailureResult():
        _currentPage--; // roll back page
        emit(SpecialistDailyTasksSuccess(
          tasks: List.from(_allTasks),
          hasReachedMax: _hasReachedMax,
        ));
    }
  }
}
