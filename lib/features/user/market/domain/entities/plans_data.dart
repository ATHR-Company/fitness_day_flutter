class CurrentSubscription {
  final String id;
  final String name;
  final String endDate;

  const CurrentSubscription({
    required this.id,
    required this.name,
    required this.endDate,
  });
}

class PlanItem {
  final String id;
  final String name;
  final String coverPhoto;
  final double price;
  final double? compareAtPrice;
  final String? badge;
  final bool isFavorite;

  const PlanItem({
    required this.id,
    required this.name,
    required this.coverPhoto,
    required this.price,
    this.compareAtPrice,
    this.badge,
    this.isFavorite = false,
  });
}

class PlanDetails {
  final String id;
  final String name;
  final String coverPhoto;
  final List<String> photos;
  final double price;
  final double? compareAtPrice;
  final String? badge;
  final List<String> descriptions;
  final bool isFavorite;

  const PlanDetails({
    required this.id,
    required this.name,
    required this.coverPhoto,
    required this.photos,
    required this.price,
    this.compareAtPrice,
    this.badge,
    required this.descriptions,
    this.isFavorite = false,
  });
}

class PlansData {
  final CurrentSubscription? currentSubscription;
  final List<PlanItem> plans;
  final int total;
  final int page;
  final int limit;

  const PlansData({
    this.currentSubscription,
    required this.plans,
    required this.total,
    required this.page,
    required this.limit,
  });

  bool get hasMore => (page * limit) < total;
}
