import '../../domain/entities/plans_data.dart';

class PlansModel {
  final CurrentSubscription? currentSubscription;
  final List<PlanItem> plans;
  final int total;
  final int page;
  final int limit;

  PlansModel({
    this.currentSubscription,
    required this.plans,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PlansModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    // current subscription
    CurrentSubscription? sub;
    final rawSub = data['currentSubscription'];
    if (rawSub != null && rawSub['id'] != null) {
      sub = CurrentSubscription(
        id: rawSub['id'] ?? '',
        name: rawSub['name'] ?? '',
        endDate: rawSub['endDate'] ?? '',
      );
    }

    // plans list
    final rawPlans = data['plans'] as List? ?? [];
    final plans = rawPlans.map((e) {
      return PlanItem(
        id: e['id'] ?? '',
        name: e['name'] ?? '',
        coverPhoto: e['coverPhoto'] ?? '',
        price: (e['price'] as num?)?.toDouble() ?? 0,
        compareAtPrice: (e['compareAtPrice'] as num?)?.toDouble(),
        badge: e['badge'] as String?,
        isFavorite: e['isFavorite'] ?? false,
      );
    }).toList();

    // pagination
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return PlansModel(
      currentSubscription: sub,
      plans: plans,
      total: pagination['total'] as int? ?? 0,
      page: pagination['page'] as int? ?? 1,
      limit: pagination['limit'] as int? ?? plans.length,
    );
  }

  PlansData toEntity() {
    return PlansData(
      currentSubscription: currentSubscription,
      plans: plans,
      total: total,
      page: page,
      limit: limit,
    );
  }
}
