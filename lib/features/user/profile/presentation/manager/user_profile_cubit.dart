import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/change_password_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/request_change_phone_otp_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/toggle_user_notifications_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/update_user_lang_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/user_signout_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/verify_change_phone_otp_usecase.dart';
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
  final ChangePasswordUseCase _changePasswordUseCase;
  final RequestChangePhoneOtpUseCase _requestChangePhoneOtpUseCase;
  final VerifyChangePhoneOtpUseCase _verifyChangePhoneOtpUseCase;
  final UserSignoutUseCase _userSignoutUseCase;
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
    this._changePasswordUseCase,
    this._requestChangePhoneOtpUseCase,
    this._verifyChangePhoneOtpUseCase,
    this._userSignoutUseCase,
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
      case FailureResult(:final failure):
        emit(UserProfileUpdateFailure(failure.message));
        // Re-emit the last good state so the toggle reflects the unchanged
        // server value rather than getting stuck on the failure state.
        if (profileData != null) emit(UserProfileSuccess(profileData!));
    }
  }

  Future<void> updateLang(String lang) async {
    final result = await _updateUserLangUseCase(lang);
    switch (result) {
      case Success(:final data):
        profileData = (profileData ?? _placeholderData()).copyWith(lang: data.lang);
        emit(UserProfileSuccess(profileData!));
      case FailureResult(:final failure):
        emit(UserProfileUpdateFailure(failure.message));
        if (profileData != null) emit(UserProfileSuccess(profileData!));
    }
  }

  // ── Account security actions ─────────────────────────────────────────────
  // These don't affect `profileData`/emit cubit states directly — callers
  // (dialogs) manage their own local loading/error UI from the ApiResult.

  /// Result carries the API's own success message.
  Future<ApiResult<String>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) {
    return _changePasswordUseCase(
      oldPassword: oldPassword,
      newPassword: newPassword,
      newPasswordConfirm: newPasswordConfirm,
    );
  }

  Future<ApiResult<ChangePhoneOtpResponse>> requestChangePhoneOtp(String phone) {
    return _requestChangePhoneOtpUseCase(phone);
  }

  /// Result carries the API's own success message.
  Future<ApiResult<String>> verifyChangePhoneOtp({
    required String changePhoneToken,
    required String otp,
  }) async {
    final result = await _verifyChangePhoneOtpUseCase(
      changePhoneToken: changePhoneToken,
      otp: otp,
    );
    if (result is Success<String>) {
      // The phone (identifier) changed server-side — refresh to pick it up.
      await getUserProfile();
    }
    return result;
  }

  Future<ApiResult<void>> signout() {
    return _userSignoutUseCase();
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
