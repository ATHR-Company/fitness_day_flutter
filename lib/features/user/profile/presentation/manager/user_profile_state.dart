import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';

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

  const UserProfileFailure(this.message);
}

class UserProfileUpdating extends UserProfileState {
  const UserProfileUpdating();
}

class UserProfileUpdateFailure extends UserProfileState {
  final String message;

  const UserProfileUpdateFailure(this.message);
}
