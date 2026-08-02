import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/rewards/data/models/check_in_calendar_models.dart';
import 'package:fitness_day/features/user/rewards/data/models/points_reward_models.dart';
import 'package:fitness_day/features/user/rewards/data/models/redemption_models.dart';
import 'package:fitness_day/features/user/rewards/domain/usecases/get_check_in_calendar_usecase.dart';
import 'package:fitness_day/features/user/rewards/domain/usecases/get_points_rewards_usecase.dart';
import 'package:fitness_day/features/user/rewards/domain/usecases/redeem_reward_usecase.dart';
import 'package:fitness_day/core/errors/app_error.dart';

part 'awards_state.dart';

/// The awards screen: points balance, the monthly check-in grid and the
/// rewards catalog, plus redeeming a reward into a coupon code.
class AwardsCubit extends Cubit<AwardsState> {
  final GetPointsRewardsUseCase _getRewardsUseCase;
  final GetCheckInCalendarUseCase _getCalendarUseCase;
  final RedeemRewardUseCase _redeemRewardUseCase;

  AwardsCubit({
    required GetPointsRewardsUseCase getRewardsUseCase,
    required GetCheckInCalendarUseCase getCalendarUseCase,
    required RedeemRewardUseCase redeemRewardUseCase,
  })  : _getRewardsUseCase = getRewardsUseCase,
        _getCalendarUseCase = getCalendarUseCase,
        _redeemRewardUseCase = redeemRewardUseCase,
        super(const AwardsInitial());

  /// Month currently shown in the grid. `null` on first load, which asks the
  /// backend for the current UTC month rather than guessing it from the device.
  int? _year;
  int? _month;

  Future<void> load() async {
    if (isClosed) return;
    emit(const AwardsLoading());

    // Sequential, not Future.wait: the results are typed ApiResult values and
    // Future.wait would hand them back as List<dynamic>.
    final rewardsResult = await _getRewardsUseCase();
    if (isClosed) return;

    switch (rewardsResult) {
      case FailureResult(:final failure):
        emit(AwardsFailure(failure.message, error: AppError.from(failure)));
        return;
      case Success(:final data):
        emit(AwardsLoaded(
          pointsBalance: data.pointsBalance,
          rewards: data.rewards,
        ));
    }

    await _loadCalendar();
  }

  /// The grid alone — the catalog is left as it is. A failed month is not fatal
  /// for the screen, so it is swallowed rather than blanking the rewards.
  Future<void> _loadCalendar() async {
    final result = await _getCalendarUseCase(year: _year, month: _month);
    if (isClosed) return;

    final current = state;
    if (current is! AwardsLoaded) return;

    switch (result) {
      case Success(:final data):
        _year = data.year;
        _month = data.month;
        emit(current.copyWith(calendar: data));
      case FailureResult():
        break;
    }
  }

  /// Steps the grid one month back or forward. Months are 1-based, so rolling
  /// past either end moves the year.
  Future<void> changeMonth(int delta) async {
    final current = state;
    if (current is! AwardsLoaded) return;
    final CheckInCalendarModel? calendar = current.calendar;
    if (calendar == null) return;

    int year = calendar.year;
    int month = calendar.month + delta;
    if (month < 1) {
      month = 12;
      year -= 1;
    } else if (month > 12) {
      month = 1;
      year += 1;
    }
    _year = year;
    _month = month;
    await _loadCalendar();
  }

  /// Buys the coupon. Returns the redemption on success so the caller can show
  /// the code, or `null` on failure — [lastMessage] then holds the backend's
  /// own message.
  ///
  /// Safe to call again after a failure: the backend rolls the deduction back,
  /// so no points are ever lost on a failed redeem.
  Future<RedemptionModel?> redeem(String rewardId) async {
    final current = state;
    if (current is! AwardsLoaded || current.redeemingRewardId != null) {
      return null;
    }

    emit(current.copyWith(redeemingRewardId: rewardId));
    lastMessage = null;

    final result = await _redeemRewardUseCase(rewardId);
    if (isClosed) return null;

    switch (result) {
      case Success(:final data):
        // Balance and `canRedeem` both move after a purchase, so the catalog is
        // refetched instead of being adjusted here.
        emit(current.copyWith(
          pointsBalance: data.pointsBalance,
          redeemingRewardId: null,
        ));
        await refreshRewards();
        return data.redemption;
      case FailureResult(:final failure):
        lastMessage = failure.message;
        emit(current.copyWith(redeemingRewardId: null));
        return null;
    }
  }

  /// Backend message from the last failed redeem, already translated to the
  /// `lang` header that was sent.
  String? lastMessage;

  Future<void> refreshRewards() async {
    final result = await _getRewardsUseCase();
    if (isClosed) return;

    final current = state;
    if (current is! AwardsLoaded) return;

    switch (result) {
      case Success(:final data):
        emit(current.copyWith(
          pointsBalance: data.pointsBalance,
          rewards: data.rewards,
        ));
      case FailureResult():
        break;
    }
  }
}
