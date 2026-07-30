import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/user/rewards/data/models/check_in_calendar_models.dart';
import 'package:fitness_day/features/user/rewards/data/models/daily_check_in_models.dart';
import 'package:fitness_day/features/user/rewards/data/models/points_reward_models.dart';
import 'package:fitness_day/features/user/rewards/data/models/redemption_models.dart';

/// Daily check-in, points balance and reward coupons.
///
/// Every endpoint here requires a completed profile — an unfinished user gets
/// `403 messages.dataIncomplete`, which surfaces as a `ServerFailure` carrying
/// the backend's own translated message.
abstract class RewardsRemoteDataSource {
  Future<DailyCheckInStatusModel> getDailyCheckInStatus();

  Future<DailyCheckInStatusModel> claimDailyCheckIn();

  Future<CheckInCalendarModel> getCheckInCalendar({int? year, int? month});

  Future<PointsRewardsModel> getPointsRewards();

  Future<RedeemRewardResultModel> redeemReward(String rewardId);

  Future<RedemptionsPageModel> getRedemptions({int page, int limit});
}

class RewardsRemoteDataSourceImpl implements RewardsRemoteDataSource {
  final ApiService _apiService;

  RewardsRemoteDataSourceImpl(this._apiService);

  @override
  Future<DailyCheckInStatusModel> getDailyCheckInStatus() async {
    final response = await _apiService.get(ApiEndpoints.dailyCheckInStatus);
    return DailyCheckInStatusModel.fromJson(_data(response.data));
  }

  @override
  Future<DailyCheckInStatusModel> claimDailyCheckIn() async {
    // No body at all — the server decides which cycle day it is.
    final response = await _apiService.post(ApiEndpoints.dailyCheckInClaim);
    return DailyCheckInStatusModel.fromJson(_data(response.data));
  }

  @override
  Future<CheckInCalendarModel> getCheckInCalendar({int? year, int? month}) async {
    // Both params are optional and default to the current UTC month.
    final Map<String, dynamic> query = {};
    if (year != null) query['year'] = year;
    if (month != null) query['month'] = month;

    final response = await _apiService.get(
      ApiEndpoints.dailyCheckInCalendar,
      queryParameters: query.isNotEmpty ? query : null,
    );
    return CheckInCalendarModel.fromJson(_data(response.data));
  }

  @override
  Future<PointsRewardsModel> getPointsRewards() async {
    final response = await _apiService.get(ApiEndpoints.pointsRewards);
    return PointsRewardsModel.fromJson(_data(response.data));
  }

  @override
  Future<RedeemRewardResultModel> redeemReward(String rewardId) async {
    // No body.
    final response =
        await _apiService.post(ApiEndpoints.redeemPointsReward(rewardId));
    return RedeemRewardResultModel.fromJson(_data(response.data));
  }

  @override
  Future<RedemptionsPageModel> getRedemptions({int page = 1, int limit = 10}) async {
    final response = await _apiService.get(
      ApiEndpoints.pointsRedemptions,
      queryParameters: {'page': page, 'limit': limit},
    );
    // Paging fields sit next to `data`, so this one reads the whole envelope.
    final dynamic body = response.data;
    return RedemptionsPageModel.fromEnvelope(
      body is Map<String, dynamic> ? body : const <String, dynamic>{},
    );
  }

  /// Unwraps the `{ success, statusCode, message, data }` envelope.
  Map<String, dynamic> _data(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) return data;
    }
    return const <String, dynamic>{};
  }
}
