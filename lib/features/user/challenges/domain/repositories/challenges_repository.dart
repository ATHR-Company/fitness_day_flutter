import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/challenges/data/datasources/challenges_remote_datasource.dart';
import 'package:fitness_day/features/user/challenges/data/models/achievement_model.dart';
import 'package:fitness_day/features/user/challenges/data/models/activity_sync_models.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';

abstract class ChallengesRepository {
  Future<ApiResult<ActivitySyncResultModel>> pushActivity(
    ActivitySyncRequestModel request,
  );

  Future<ApiResult<ActivityTotalsModel>> getDailyTotals({String? date});

  Future<ApiResult<ChallengesPageModel>> getChallenges({
    ChallengeStatusFilter? status,
    bool? joined,
    int page,
    int limit,
  });

  Future<ApiResult<ChallengeModel>> getChallengeDetails(String id);

  Future<ApiResult<ChallengeModel>> joinChallenge(String id);

  Future<ApiResult<void>> leaveChallenge(String id);

  Future<ApiResult<AchievementsWallModel>> getAchievements();

  Future<ApiResult<AchievementsDailyModel>> getDailyAchievements({String? date});
}
