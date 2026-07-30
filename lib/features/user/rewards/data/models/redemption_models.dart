/// The coupon behind a redemption, as embedded in the redemption documents.
class RedemptionCouponModel {
  final String id;
  final String name;
  final String? description;
  final int discountPercentage;
  final num? maxDiscountAmount;
  final num? minOrderAmount;
  final String? expiresAt;

  const RedemptionCouponModel({
    required this.id,
    required this.name,
    required this.discountPercentage,
    this.description,
    this.maxDiscountAmount,
    this.minOrderAmount,
    this.expiresAt,
  });

  factory RedemptionCouponModel.fromJson(Map<String, dynamic> json) {
    return RedemptionCouponModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      discountPercentage: (json['discountPercentage'] as num?)?.toInt() ?? 0,
      maxDiscountAmount: json['maxDiscountAmount'] as num?,
      minOrderAmount: json['minOrderAmount'] as num?,
      expiresAt: json['expiresAt'] as String?,
    );
  }
}

/// A coupon the user has already paid points for.
class RedemptionModel {
  final String id;

  /// What the user types at checkout. Shared between everyone who buys the same
  /// reward, so the backend still checks *this* user owns an unused redemption.
  final String code;
  final int pointsSpent;

  /// `AVAILABLE` (still usable) or `USED` (consumed on a paid order).
  final String status;
  final String? usedAt;
  final String? redeemedAt;
  final RedemptionCouponModel? coupon;

  const RedemptionModel({
    required this.id,
    required this.code,
    required this.pointsSpent,
    required this.status,
    this.usedAt,
    this.redeemedAt,
    this.coupon,
  });

  bool get isUsed => status == 'USED';

  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawCoupon = json['coupon'];
    return RedemptionModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      pointsSpent: (json['pointsSpent'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      usedAt: json['usedAt'] as String?,
      redeemedAt: json['redeemedAt'] as String?,
      coupon: rawCoupon is Map<String, dynamic>
          ? RedemptionCouponModel.fromJson(rawCoupon)
          : null,
    );
  }
}

/// `POST /points/rewards/:id/redeem` — the new balance plus the coupon just
/// bought. Take the balance from here rather than subtracting locally.
class RedeemRewardResultModel {
  final int pointsBalance;
  final RedemptionModel? redemption;

  const RedeemRewardResultModel({
    required this.pointsBalance,
    this.redemption,
  });

  factory RedeemRewardResultModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawRedemption = json['redemption'];
    return RedeemRewardResultModel(
      pointsBalance: (json['pointsBalance'] as num?)?.toInt() ?? 0,
      redemption: rawRedemption is Map<String, dynamic>
          ? RedemptionModel.fromJson(rawRedemption)
          : null,
    );
  }
}

/// `GET /points/redemptions` — note the paging fields sit **next to** `data`,
/// not inside it, so this is built from the whole envelope.
class RedemptionsPageModel {
  final List<RedemptionModel> redemptions;
  final int totalCount;
  final int page;
  final int totalPages;

  const RedemptionsPageModel({
    required this.redemptions,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  factory RedemptionsPageModel.fromEnvelope(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];
    return RedemptionsPageModel(
      redemptions: rawData is List
          ? rawData
              .whereType<Map<String, dynamic>>()
              .map(RedemptionModel.fromJson)
              .toList()
          : const <RedemptionModel>[],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  bool get hasMore => page < totalPages;
}
