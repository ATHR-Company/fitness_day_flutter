class DailyTasksModel {
  final String? assessmentId;
  final int? dayNumber;
  final Map<String, dynamic>? currentMeal;
  final Map<String, dynamic>? currentWorkoutItem;
  final Map<String, dynamic>? currentActivity;

  DailyTasksModel({
    this.assessmentId,
    this.dayNumber,
    this.currentMeal,
    this.currentWorkoutItem,
    this.currentActivity,
  });

  factory DailyTasksModel.fromJson(Map<String, dynamic> json) {
    return DailyTasksModel(
      assessmentId: json['assessmentId'],
      dayNumber: json['dayNumber'],
      currentMeal: json['currentMeal'],
      currentWorkoutItem: json['currentWorkoutItem'],
      currentActivity: json['currentActivity'],
    );
  }

  /// Lets a single task be replaced without refetching the whole home payload.
  DailyTasksModel copyWith({
    Map<String, dynamic>? currentMeal,
    Map<String, dynamic>? currentWorkoutItem,
    Map<String, dynamic>? currentActivity,
  }) {
    return DailyTasksModel(
      assessmentId: assessmentId,
      dayNumber: dayNumber,
      currentMeal: currentMeal ?? this.currentMeal,
      currentWorkoutItem: currentWorkoutItem ?? this.currentWorkoutItem,
      currentActivity: currentActivity ?? this.currentActivity,
    );
  }
}

class BannerModel {
  final String? id;
  final String? photo;
  final int? order;

  BannerModel({this.id, this.photo, this.order});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      photo: json['photo'],
      order: json['order'],
    );
  }
}

/// The `subscription` block of `GET /user-home`, present only while the user
/// has an active plan.
///
/// [planId] is what lets the home screen reopen the plan through
/// `GET /plans/:id`. The backend has spelled the reference differently across
/// versions, so it is resolved from whichever form the payload carries:
/// a flat `planId`, a nested `plan` object/string, or the block's own `id`.
class HomeSubscriptionModel {
  final String? planId;
  final String? name;
  final String? endDate;

  const HomeSubscriptionModel({this.planId, this.name, this.endDate});

  factory HomeSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return HomeSubscriptionModel(
      planId: _resolvePlanId(json),
      name: json['name'] as String?,
      endDate: json['endDate'] as String?,
    );
  }

  static String? _resolvePlanId(Map<String, dynamic> json) {
    final plan = json['plan'];
    final candidates = <dynamic>[
      json['planId'],
      if (plan is Map) plan['id'] ?? plan['_id'],
      if (plan is String) plan,
      json['id'],
      json['_id'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.isNotEmpty) return candidate;
    }
    return null;
  }
}

class HomePlanModel {
  final String id;
  final String name;
  final String coverPhoto;
  final double price;
  final double? compareAtPrice;
  final String? badge;

  HomePlanModel({
    required this.id,
    required this.name,
    required this.coverPhoto,
    required this.price,
    this.compareAtPrice,
    this.badge,
  });

  factory HomePlanModel.fromJson(Map<String, dynamic> json) {
    return HomePlanModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      coverPhoto: json['coverPhoto'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
      badge: json['badge'] as String?,
    );
  }
}

class UserHomeDataModel {
  final Map<String, dynamic>? user;
  final HomeSubscriptionModel? subscription;
  final Map<String, dynamic>? currentWeight;
  final Map<String, dynamic>? visits;
  final DailyTasksModel? dailyTasks;
  final List<BannerModel> banners;

  /// Subscription plans offered on the home screen. Returned by `/user-home`
  /// for users without an active subscription.
  final List<HomePlanModel> plans;

  UserHomeDataModel({
    this.user,
    this.subscription,
    this.currentWeight,
    this.visits,
    this.dailyTasks,
    this.banners = const [],
    this.plans = const [],
  });

  factory UserHomeDataModel.fromJson(Map<String, dynamic> json) {
    return UserHomeDataModel(
      user: json['user'],
      subscription: json['subscription'] is Map
          ? HomeSubscriptionModel.fromJson(
              Map<String, dynamic>.from(json['subscription'] as Map))
          : null,
      currentWeight: json['currentWeight'],
      visits: json['visits'],
      dailyTasks: json['dailyTasks'] != null ? DailyTasksModel.fromJson(json['dailyTasks']) : null,
      banners: json['banners'] != null
          ? (json['banners'] as List).map((i) => BannerModel.fromJson(i)).toList()
          : [],
      plans: json['plans'] != null
          ? (json['plans'] as List)
              .map((i) => HomePlanModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  /// Swaps in a patched [dailyTasks] and shares every other field by reference —
  /// nothing else on the home payload can change without a refetch.
  UserHomeDataModel copyWith({DailyTasksModel? dailyTasks}) {
    return UserHomeDataModel(
      user: user,
      subscription: subscription,
      currentWeight: currentWeight,
      visits: visits,
      dailyTasks: dailyTasks ?? this.dailyTasks,
      banners: banners,
      plans: plans,
    );
  }
}

class UserHomeResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final UserHomeDataModel? data;

  UserHomeResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory UserHomeResponseModel.fromJson(Map<String, dynamic> json) {
    return UserHomeResponseModel(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 200,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserHomeDataModel.fromJson(json['data']) : null,
    );
  }
}
