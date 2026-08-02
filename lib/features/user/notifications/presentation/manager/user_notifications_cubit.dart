import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/notifications/data/models/user_notification_model.dart';
import 'package:fitness_day/features/user/notifications/domain/usecases/get_user_notifications_usecase.dart';
import 'package:fitness_day/features/user/notifications/domain/usecases/toggle_user_notification_read_usecase.dart';
import 'user_notifications_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class UserNotificationsCubit extends Cubit<UserNotificationsState> {
  final GetUserNotificationsUseCase _getUserNotificationsUseCase;
  final ToggleUserNotificationReadUseCase _toggleUserNotificationReadUseCase;

  int _currentPage = 1;
  static const int _limit = 10;
  final List<UserNotificationItemModel> _allNotifications = [];
  bool _hasReachedMax = false;

  UserNotificationsCubit(
    this._getUserNotificationsUseCase,
    this._toggleUserNotificationReadUseCase,
  ) : super(const UserNotificationsInitial());

  Future<void> getNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _allNotifications.clear();
      _hasReachedMax = false;
    }

    emit(const UserNotificationsLoading());

    final result = await _getUserNotificationsUseCase(
      page: _currentPage,
      limit: _limit,
    );

    switch (result) {
      case Success(:final data):
        _allNotifications.addAll(data.data);
        _hasReachedMax = _allNotifications.length >= data.totalCount || data.data.isEmpty;
        emit(UserNotificationsSuccess(
          notifications: List.from(_allNotifications),
          hasReachedMax: _hasReachedMax,
        ));
      case FailureResult(:final failure):
        emit(UserNotificationsFailure(failure.message, error: AppError.from(failure)));
    }
  }

  Future<void> loadMoreNotifications() async {
    if (state is UserNotificationsLoading ||
        state is UserNotificationsLoadingMore ||
        _hasReachedMax) {
      return;
    }

    emit(UserNotificationsLoadingMore(List.from(_allNotifications)));

    _currentPage++;

    final result = await _getUserNotificationsUseCase(
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
        emit(UserNotificationsSuccess(
          notifications: List.from(_allNotifications),
          hasReachedMax: _hasReachedMax,
        ));
      case FailureResult():
        _currentPage--;
        emit(UserNotificationsSuccess(
          notifications: List.from(_allNotifications),
          hasReachedMax: _hasReachedMax,
        ));
    }
  }

  Future<void> toggleRead(String notificationId) async {
    final result = await _toggleUserNotificationReadUseCase(notificationId: notificationId);

    switch (result) {
      case Success(:final data):
        final index = _allNotifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _allNotifications[index] = data.data;
        }
        emit(UserNotificationsSuccess(
          notifications: List.from(_allNotifications),
          hasReachedMax: _hasReachedMax,
        ));
      case FailureResult():
        break;
    }
  }
}
