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

class UserHomeDataModel {
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? subscription;
  final Map<String, dynamic>? currentWeight;
  final Map<String, dynamic>? visits;
  final DailyTasksModel? dailyTasks;
  final List<BannerModel> banners;

  UserHomeDataModel({
    this.user,
    this.subscription,
    this.currentWeight,
    this.visits,
    this.dailyTasks,
    this.banners = const [],
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
