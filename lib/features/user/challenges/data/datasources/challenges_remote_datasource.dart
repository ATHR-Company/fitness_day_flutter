import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/user/challenges/data/models/achievement_model.dart';
import 'package:fitness_day/features/user/challenges/data/models/activity_sync_models.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';

/// Which slice of the list the tab is asking for.
enum ChallengeStatusFilter {
  active,
  upcoming,
  ended;

  String get wireValue => switch (this) {
        ChallengeStatusFilter.active => 'active',
        ChallengeStatusFilter.upcoming => 'upcoming',
        ChallengeStatusFilter.ended => 'ended',
      };
}

/// Every call in the challenges/achievements product. Throws `DioException`;
/// the repository maps that to a `Failure`.
abstract class ChallengesRemoteDataSource {
  Future<ActivitySyncResultModel> pushActivity(ActivitySyncRequestModel request);

  /// [date] as `YYYY-MM-DD`; omitted means today.
  Future<ActivityTotalsModel> getDailyTotals({String? date});

  /// [status] omitted means "everything not finished yet" — active plus
  /// upcoming, which is what the screen opens on.
  Future<ChallengesPageModel> getChallenges({
    ChallengeStatusFilter? status,
    bool? joined,
    int page,
    int limit,
  });

  Future<ChallengeModel> getChallengeDetails(String id);

  /// Returns the details object, already reflecting the join — no refetch.
  Future<ChallengeModel> joinChallenge(String id);

  Future<void> leaveChallenge(String id);

  Future<AchievementsWallModel> getAchievements();

  Future<AchievementsDailyModel> getDailyAchievements({String? date});
}

class ChallengesRemoteDataSourceImpl implements ChallengesRemoteDataSource {
  final ApiService _apiService;

  ChallengesRemoteDataSourceImpl(this._apiService);

  @override
  Future<ActivitySyncResultModel> pushActivity(
    ActivitySyncRequestModel request,
  ) async {
    final response = await _apiService.post(
      ApiEndpoints.activitySync,
      data: request.toJson(),
    );
    return ActivitySyncResultModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ActivityTotalsModel> getDailyTotals({String? date}) async {
    final response = await _apiService.get(
      ApiEndpoints.activitySyncDaily,
      queryParameters: {'date': ?date},
    );
    final data = (response.data as Map<String, dynamic>)['data'];
    return ActivityTotalsModel.fromJson(
      data as Map<String, dynamic>? ?? const {},
    );
  }

  @override
  Future<ChallengesPageModel> getChallenges({
    ChallengeStatusFilter? status,
    bool? joined,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.challenges,
      queryParameters: {
        'status': ?status?.wireValue,
        'joined': ?joined,
        'page': page,
        'limit': limit,
      },
    );
    return ChallengesPageModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ChallengeModel> getChallengeDetails(String id) async {
    final response = await _apiService.get(ApiEndpoints.challengeById(id));
    return _challengeFromEnvelope(response.data);
  }

  @override
  Future<ChallengeModel> joinChallenge(String id) async {
    final response = await _apiService.post(ApiEndpoints.joinChallenge(id));
    return _challengeFromEnvelope(response.data);
  }

  @override
  Future<void> leaveChallenge(String id) async {
    await _apiService.delete(ApiEndpoints.leaveChallenge(id));
  }

  @override
  Future<AchievementsWallModel> getAchievements() async {
    final response = await _apiService.get(ApiEndpoints.achievements);
    return AchievementsWallModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AchievementsDailyModel> getDailyAchievements({String? date}) async {
    final response = await _apiService.get(
      ApiEndpoints.achievementsDaily,
      queryParameters: {'date': ?date},
    );
    return AchievementsDailyModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  ChallengeModel _challengeFromEnvelope(dynamic body) {
    final data = (body as Map<String, dynamic>)['data'];
    return ChallengeModel.fromJson(data as Map<String, dynamic>? ?? const {});
  }
}
