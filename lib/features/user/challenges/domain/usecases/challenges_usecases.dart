import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/challenges/data/datasources/challenges_remote_datasource.dart';
import 'package:fitness_day/features/user/challenges/data/models/achievement_model.dart';
import 'package:fitness_day/features/user/challenges/data/models/activity_sync_models.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/domain/repositories/challenges_repository.dart';

/// Pushes a delta to the challenges/achievements ledger.
///
/// Deliberately separate from the plan's walking/running/hydration sync: the
/// same numbers go to both, and neither is derived from the other.
class PushActivityUseCase {
  final ChallengesRepository _repository;
  PushActivityUseCase(this._repository);

  Future<ApiResult<ActivitySyncResultModel>> call(
    ActivitySyncRequestModel request,
  ) =>
      _repository.pushActivity(request);
}

/// The day's stored totals — call before the first sync of a session so a
/// reinstall doesn't re-send a whole day.
class GetDailyTotalsUseCase {
  final ChallengesRepository _repository;
  GetDailyTotalsUseCase(this._repository);

  Future<ApiResult<ActivityTotalsModel>> call({String? date}) =>
      _repository.getDailyTotals(date: date);
}

class GetChallengesUseCase {
  final ChallengesRepository _repository;
  GetChallengesUseCase(this._repository);

  Future<ApiResult<ChallengesPageModel>> call({
    ChallengeStatusFilter? status,
    bool? joined,
    int page = 1,
    int limit = 10,
  }) =>
      _repository.getChallenges(
        status: status,
        joined: joined,
        page: page,
        limit: limit,
      );
}

class GetChallengeDetailsUseCase {
  final ChallengesRepository _repository;
  GetChallengeDetailsUseCase(this._repository);

  Future<ApiResult<ChallengeModel>> call(String id) =>
      _repository.getChallengeDetails(id);
}

class JoinChallengeUseCase {
  final ChallengesRepository _repository;
  JoinChallengeUseCase(this._repository);

  Future<ApiResult<ChallengeModel>> call(String id) =>
      _repository.joinChallenge(id);
}

class LeaveChallengeUseCase {
  final ChallengesRepository _repository;
  LeaveChallengeUseCase(this._repository);

  Future<ApiResult<void>> call(String id) => _repository.leaveChallenge(id);
}

class GetAchievementsUseCase {
  final ChallengesRepository _repository;
  GetAchievementsUseCase(this._repository);

  Future<ApiResult<AchievementsWallModel>> call() =>
      _repository.getAchievements();
}

class GetDailyAchievementsUseCase {
  final ChallengesRepository _repository;
  GetDailyAchievementsUseCase(this._repository);

  Future<ApiResult<AchievementsDailyModel>> call({String? date}) =>
      _repository.getDailyAchievements(date: date);
}
