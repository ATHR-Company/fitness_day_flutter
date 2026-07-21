class UserNotificationsResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final List<UserNotificationItemModel> data;
  final int totalCount;
  final int page;
  final int totalPages;

  UserNotificationsResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  factory UserNotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return UserNotificationsResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => UserNotificationItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class UserToggleNotificationReadResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final UserNotificationItemModel data;

  UserToggleNotificationReadResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory UserToggleNotificationReadResponseModel.fromJson(Map<String, dynamic> json) {
    return UserToggleNotificationReadResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: UserNotificationItemModel.fromJson(json['data'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

class UserNotificationItemModel {
  final String id;
  final String title;
  final String message;
  final String image;
  final String key;
  final bool read;
  final String createdAt;
  final Map<String, dynamic> data;

  UserNotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.image,
    required this.key,
    required this.read,
    required this.createdAt,
    required this.data,
  });

  factory UserNotificationItemModel.fromJson(Map<String, dynamic> json) {
    return UserNotificationItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      image: json['image'] as String? ?? '',
      key: json['key'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      data: (json['data'] as Map<String, dynamic>?) ?? const {},
    );
  }
}
