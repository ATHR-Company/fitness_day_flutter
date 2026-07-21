import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/toggle_user_notifications_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/update_user_lang_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/update_user_profile_usecase.dart';
import 'user_profile_state.dart';

/// `GET /users/my-profile` doesn't return weight/height/goal — only the
/// update endpoint echoes them back. These fields mirror the last known
/// values (seeded from local cache, refreshed after a successful update) so
/// the edit screen has something to prefill.
class UserProfileCubit extends Cubit<UserProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final ToggleUserNotificationsUseCase _toggleUserNotificationsUseCase;
  final UpdateUserLangUseCase _updateUserLangUseCase;
  final AppCache _appCache;

  UserProfileDataModel? profileData;
  String? lastKnownGoalId;
  double? lastKnownWeight;
  double? lastKnownHeight;

  UserProfileCubit(
    this._getUserProfileUseCase,
    this._updateUserProfileUseCase,
    this._toggleUserNotificationsUseCase,
    this._updateUserLangUseCase,
    this._appCache,
  ) : super(const UserProfileInitial()) {
    final cachedUser = _appCache.getUser();
    lastKnownGoalId = cachedUser.goal;
    lastKnownWeight = cachedUser.weight;
    lastKnownHeight = cachedUser.height;
  }

  Future<void> getUserProfile() async {
    emit(const UserProfileLoading());
    final result = await _getUserProfileUseCase();
    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          profileData = data.data;
          emit(UserProfileSuccess(profileData!));
        } else {
          emit(const UserProfileFailure('بيانات فارغة'));
        }
      case FailureResult(:final failure):
        emit(UserProfileFailure(failure.message));
    }
  }

  Future<void> updateUserProfile({
    String? fullName,
    String? goalId,
    String? weight,
    String? height,
    String? avatarPath,
  }) async {
    emit(const UserProfileUpdating());
    final result = await _updateUserProfileUseCase(
      fullName: fullName,
      goalId: goalId,
      weight: weight,
      height: height,
      avatarPath: avatarPath,
    );
    switch (result) {
      case Success(:final data):
        final updated = data.data;
        if (updated != null) {
          lastKnownGoalId = updated.goal ?? lastKnownGoalId;
          lastKnownWeight = updated.weight ?? lastKnownWeight;
          lastKnownHeight = updated.height ?? lastKnownHeight;
          profileData = (profileData ?? _placeholderData()).copyWith(
            fullName: updated.fullName,
            avatar: updated.avatar,
          );
          await _appCache.saveUser(_appCache.getUser().copyWith(
                name: updated.fullName,
                weight: lastKnownWeight,
                height: lastKnownHeight,
                goal: lastKnownGoalId,
              ));
        }
        emit(UserProfileSuccess(profileData!));
      case FailureResult(:final failure):
        emit(UserProfileUpdateFailure(failure.message));
    }
  }

  Future<void> toggleNotifications() async {
    final result = await _toggleUserNotificationsUseCase();
    switch (result) {
      case Success(:final data):
        profileData = (profileData ?? _placeholderData()).copyWith(
          notificationsEnabled: data.notificationsEnabled,
        );
        emit(UserProfileSuccess(profileData!));
      case FailureResult():
        break;
    }
  }

  Future<void> updateLang(String lang) async {
    final result = await _updateUserLangUseCase(lang);
    switch (result) {
      case Success(:final data):
        profileData = (profileData ?? _placeholderData()).copyWith(lang: data.lang);
        emit(UserProfileSuccess(profileData!));
      case FailureResult():
        break;
    }
  }

  UserProfileDataModel _placeholderData() {
    final cachedUser = _appCache.getUser();
    return UserProfileDataModel(
      fullName: cachedUser.name,
      avatar: '',
      lang: 'ar',
      notificationsEnabled: true,
      identifier: cachedUser.email.isNotEmpty ? cachedUser.email : cachedUser.phone,
      typeOfIdentifier: '',
    );
  }
}
