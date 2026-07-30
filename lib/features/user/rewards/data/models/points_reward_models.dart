/// A coupon the user can buy with points.
///
/// Deliberately has **no `code`** — the code only exists after a successful
/// redeem, because the user has not paid for it yet.
class PointsRewardModel {
  final String id;
  final String name;
  final String? description;
  final int discountPercentage;

  /// `null` = no cap; otherwise the discount stops at this amount.
  final num? maxDiscountAmount;

  /// The coupon does nothing below this order total.
  final num minOrderAmount;
  final int pointsCost;

  /// Already clamped to `0..100` by the backend — do not recompute it.
  final int progressPercentage;
  final int remainingPoints;

  /// False for two different reasons: not enough points, or the per-user limit
  /// is used up. [remainingPoints] `> 0` tells which.
  final bool canRedeem;
  final int redeemedCount;
  final String? expiresAt;

  const PointsRewardModel({
    required this.id,
    required this.name,
    required this.discountPercentage,
    required this.minOrderAmount,
    required this.pointsCost,
    required this.progressPercentage,
    required this.remainingPoints,
    required this.canRedeem,
    required this.redeemedCount,
    this.description,
    this.maxDiscountAmount,
    this.expiresAt,
  });

  factory PointsRewardModel.fromJson(Map<String, dynamic> json) {
    return PointsRewardModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      discountPercentage: (json['discountPercentage'] as num?)?.toInt() ?? 0,
      maxDiscountAmount: json['maxDiscountAmount'] as num?,
      minOrderAmount: json['minOrderAmount'] as num? ?? 0,
      pointsCost: (json['pointsCost'] as num?)?.toInt() ?? 0,
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
      remainingPoints: (json['remainingPoints'] as num?)?.toInt() ?? 0,
      canRedeem: json['canRedeem'] as bool? ?? false,
      redeemedCount: (json['redeemedCount'] as num?)?.toInt() ?? 0,
      expiresAt: json['expiresAt'] as String?,
    );
  }
}

class PointsRewardsModel {
  final int pointsBalance;
  final List<PointsRewardModel> rewards;

  const PointsRewardsModel({
    required this.pointsBalance,
    required this.rewards,
  });

  factory PointsRewardsModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawRewards = json['rewards'];
    return PointsRewardsModel(
      pointsBalance: (json['pointsBalance'] as num?)?.toInt() ?? 0,
      rewards: rawRewards is List
          ? rawRewards
              .whereType<Map<String, dynamic>>()
              .map(PointsRewardModel.fromJson)
              .toList()
          : const <PointsRewardModel>[],
    );
  }
}
