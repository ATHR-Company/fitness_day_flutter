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
  final Map<String, dynamic>? subscription;
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
      subscription: json['subscription'],
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
