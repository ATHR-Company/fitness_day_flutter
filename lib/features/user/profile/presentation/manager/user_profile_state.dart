import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class UserProfileState {
  const UserProfileState();
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileSuccess extends UserProfileState {
  final UserProfileDataModel data;

  const UserProfileSuccess(this.data);
}

class UserProfileFailure extends UserProfileState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const UserProfileFailure(this.message, {this.error});
}

class UserProfileUpdating extends UserProfileState {
  const UserProfileUpdating();
}

class UserProfileUpdateFailure extends UserProfileState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const UserProfileUpdateFailure(this.message, {this.error});
}
