import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/rewards/data/models/check_in_calendar_models.dart';
import 'package:fitness_day/features/user/rewards/data/models/daily_check_in_models.dart';
import 'package:fitness_day/features/user/rewards/data/models/points_reward_models.dart';
import 'package:fitness_day/features/user/rewards/data/models/redemption_models.dart';

abstract class RewardsRepository {
  Future<ApiResult<DailyCheckInStatusModel>> getDailyCheckInStatus();

  Future<ApiResult<DailyCheckInStatusModel>> claimDailyCheckIn();

  Future<ApiResult<CheckInCalendarModel>> getCheckInCalendar({
    int? year,
    int? month,
  });

  Future<ApiResult<PointsRewardsModel>> getPointsRewards();

  Future<ApiResult<RedeemRewardResultModel>> redeemReward(String rewardId);

  Future<ApiResult<RedemptionsPageModel>> getRedemptions({
    int page,
    int limit,
  });
}
