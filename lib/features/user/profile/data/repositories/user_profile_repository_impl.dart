import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/features/user/profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';
import 'package:fitness_day/features/user/profile/domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;

  UserProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<UserProfileResponseModel>> getUserProfile() async {
    try {
      final response = await remoteDataSource.getUserProfile();
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<UserProfileUpdateResponseModel>> updateUserProfile({
    String? fullName,
    String? goalId,
    String? weight,
    String? height,
    String? avatarPath,
  }) async {
    try {
      final response = await remoteDataSource.updateUserProfile(
        fullName: fullName,
        goalId: goalId,
        weight: weight,
        height: height,
        avatarPath: avatarPath,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<UserProfileDataModel>> toggleNotifications() async {
    try {
      final response = await remoteDataSource.toggleNotifications();
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<UserProfileDataModel>> updateLang(String lang) async {
    try {
      final response = await remoteDataSource.updateLang(lang);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
