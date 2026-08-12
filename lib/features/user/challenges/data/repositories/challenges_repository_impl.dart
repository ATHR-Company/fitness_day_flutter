import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/challenges/data/datasources/challenges_remote_datasource.dart';
import 'package:fitness_day/features/user/challenges/data/models/achievement_model.dart';
import 'package:fitness_day/features/user/challenges/data/models/activity_sync_models.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/domain/repositories/challenges_repository.dart';

class ChallengesRepositoryImpl implements ChallengesRepository {
  final ChallengesRemoteDataSource _remoteDataSource;

  ChallengesRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<ActivitySyncResultModel>> pushActivity(
    ActivitySyncRequestModel request,
  ) async {
    try {
      return Success(await _remoteDataSource.pushActivity(request));
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ActivityTotalsModel>> getDailyTotals({String? date}) async {
    try {
      return Success(await _remoteDataSource.getDailyTotals(date: date));
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ChallengesPageModel>> getChallenges({
    ChallengeStatusFilter? status,
    bool? joined,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return Success(await _remoteDataSource.getChallenges(
        status: status,
        joined: joined,
        page: page,
        limit: limit,
      ));
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ChallengeModel>> getChallengeDetails(String id) async {
    try {
      return Success(await _remoteDataSource.getChallengeDetails(id));
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ChallengeModel>> joinChallenge(String id) async {
    try {
      return Success(await _remoteDataSource.joinChallenge(id));
    } catch (e) {
      // Already joined / already ended arrive as 400s carrying a translated
      // message — passed through as-is, never reworded here.
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> leaveChallenge(String id) async {
    try {
      await _remoteDataSource.leaveChallenge(id);
      return const Success(null);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<AchievementsWallModel>> getAchievements() async {
    try {
      return Success(await _remoteDataSource.getAchievements());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<AchievementsDailyModel>> getDailyAchievements({
    String? date,
  }) async {
    try {
      return Success(await _remoteDataSource.getDailyAchievements(date: date));
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
