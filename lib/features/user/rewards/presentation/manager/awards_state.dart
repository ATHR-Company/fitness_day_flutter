part of 'awards_cubit.dart';

sealed class AwardsState {
  const AwardsState();
}

class AwardsInitial extends AwardsState {
  const AwardsInitial();
}

class AwardsLoading extends AwardsState {
  const AwardsLoading();
}

class AwardsLoaded extends AwardsState {
  /// Always the balance from the most recent response — never a locally
  /// adjusted number.
  final int pointsBalance;
  final List<PointsRewardModel> rewards;

  /// `null` while the month is still loading or if it failed on its own; the
  /// rewards list stays usable either way.
  final CheckInCalendarModel? calendar;

  /// Id of the reward whose redeem call is in flight, so only that card locks.
  final String? redeemingRewardId;

  const AwardsLoaded({
    required this.pointsBalance,
    required this.rewards,
    this.calendar,
    this.redeemingRewardId,
  });

  AwardsLoaded copyWith({
    int? pointsBalance,
    List<PointsRewardModel>? rewards,
    CheckInCalendarModel? calendar,
    String? redeemingRewardId,
  }) {
    return AwardsLoaded(
      pointsBalance: pointsBalance ?? this.pointsBalance,
      rewards: rewards ?? this.rewards,
      calendar: calendar ?? this.calendar,
      redeemingRewardId: redeemingRewardId,
    );
  }
}

class AwardsFailure extends AwardsState {
  final String message;

  const AwardsFailure(this.message);
}
