import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/notifications/data/models/specialist_notification_model.dart';
import 'package:fitness_day/features/specialist/notifications/domain/usecases/get_specialist_notifications_usecase.dart';
import 'package:fitness_day/features/specialist/notifications/domain/usecases/toggle_notification_read_usecase.dart';
import 'specialist_notifications_state.dart';

class SpecialistNotificationsCubit extends Cubit<SpecialistNotificationsState> {
  final GetSpecialistNotificationsUseCase _getSpecialistNotificationsUseCase;
  final ToggleNotificationReadUseCase _toggleNotificationReadUseCase;

  int _currentPage = 1;
  static const int _limit = 10;
  final List<SpecialistNotificationItemModel> _allNotifications = [];
  bool _hasReachedMax = false;

  SpecialistNotificationsCubit(
    this._getSpecialistNotificationsUseCase,
    this._toggleNotificationReadUseCase,
  ) : super(const SpecialistNotificationsInitial());

  Future<void> getNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _allNotifications.clear();
      _hasReachedMax = false;
    }

    emit(const SpecialistNotificationsLoading());

    final result = await _getSpecialistNotificationsUseCase(
      page: _currentPage,
      limit: _limit,
    );

    switch (result) {
      case Success(:final data):
        _allNotifications.addAll(data.data);
        _hasReachedMax = _allNotifications.length >= data.totalCount || data.data.isEmpty;
        emit(SpecialistNotificationsSuccess(
          notifications: List.from(_allNotifications),
          hasReachedMax: _hasReachedMax,
        ));
      case FailureResult(:final failure):
        emit(SpecialistNotificationsFailure(failure.message));
    }
  }

  Future<void> loadMoreNotifications() async {
    if (state is SpecialistNotificationsLoading ||
        state is SpecialistNotificationsLoadingMore ||
        _hasReachedMax) {
      return;
    }

    emit(SpecialistNotificationsLoadingMore(List.from(_allNotifications)));

    _currentPage++;

    final result = await _getSpecialistNotificationsUseCase(
      page: _currentPage,
      limit: _limit,
    );

    switch (result) {
      case Success(:final data):
        if (data.data.isEmpty) {
          _hasReachedMax = true;
        } else {
          _allNotifications.addAll(data.data);
          _hasReachedMax = _allNotifications.length >= data.totalCount;
        }
        emit(SpecialistNotificationsSuccess(
          notifications: List.from(_allNotifications),
          hasReachedMax: _hasReachedMax,
        ));
      case FailureResult():
        _currentPage--;
        emit(SpecialistNotificationsSuccess(
          notifications: List.from(_allNotifications),
          hasReachedMax: _hasReachedMax,
        ));
    }
  }

  Future<void> toggleRead(String notificationId) async {
    final result = await _toggleNotificationReadUseCase(notificationId: notificationId);

    switch (result) {
      case Success(:final data):
        final index = _allNotifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _allNotifications[index] = data.data;
        }
        emit(SpecialistNotificationsSuccess(
          notifications: List.from(_allNotifications),
          hasReachedMax: _hasReachedMax,
        ));
      case FailureResult():
        break;
    }
  }
}
