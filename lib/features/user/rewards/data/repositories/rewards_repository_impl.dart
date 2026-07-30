import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/rewards/data/datasources/rewards_remote_datasource.dart';
import 'package:fitness_day/features/user/rewards/data/models/check_in_calendar_models.dart';
import 'package:fitness_day/features/user/rewards/data/models/daily_check_in_models.dart';
import 'package:fitness_day/features/user/rewards/data/models/points_reward_models.dart';
import 'package:fitness_day/features/user/rewards/data/models/redemption_models.dart';
import 'package:fitness_day/features/user/rewards/domain/repositories/rewards_repository.dart';

class RewardsRepositoryImpl implements RewardsRepository {
  final RewardsRemoteDataSource _remoteDataSource;

  RewardsRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<DailyCheckInStatusModel>> getDailyCheckInStatus() async {
    try {
      return Success(await _remoteDataSource.getDailyCheckInStatus());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<DailyCheckInStatusModel>> claimDailyCheckIn() async {
    try {
      return Success(await _remoteDataSource.claimDailyCheckIn());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<CheckInCalendarModel>> getCheckInCalendar({
    int? year,
    int? month,
  }) async {
    try {
      return Success(
        await _remoteDataSource.getCheckInCalendar(year: year, month: month),
      );
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<PointsRewardsModel>> getPointsRewards() async {
    try {
      return Success(await _remoteDataSource.getPointsRewards());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<RedeemRewardResultModel>> redeemReward(String rewardId) async {
    try {
      return Success(await _remoteDataSource.redeemReward(rewardId));
    } catch (e) {
      // No points are ever lost on a failed redeem — the backend rolls the
      // deduction back, so the caller may safely let the user press again.
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<RedemptionsPageModel>> getRedemptions({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return Success(
        await _remoteDataSource.getRedemptions(page: page, limit: limit),
      );
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
