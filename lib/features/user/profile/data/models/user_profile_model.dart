class UserProfileResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final UserProfileDataModel? data;

  UserProfileResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? UserProfileDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UserProfileDataModel {
  final String fullName;
  final String avatar;
  final String lang;
  final bool notificationsEnabled;
  final String identifier;
  final String typeOfIdentifier;

  UserProfileDataModel({
    required this.fullName,
    required this.avatar,
    required this.lang,
    required this.notificationsEnabled,
    required this.identifier,
    required this.typeOfIdentifier,
  });

  factory UserProfileDataModel.fromJson(Map<String, dynamic> json) {
    return UserProfileDataModel(
      fullName: json['fullName'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      lang: json['lang'] as String? ?? 'ar',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      identifier: json['identifier'] as String? ?? '',
      typeOfIdentifier: json['typeOfIdentifier'] as String? ?? '',
    );
  }

  UserProfileDataModel copyWith({
    String? fullName,
    String? avatar,
    String? lang,
    bool? notificationsEnabled,
  }) {
    return UserProfileDataModel(
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      lang: lang ?? this.lang,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      identifier: identifier,
      typeOfIdentifier: typeOfIdentifier,
    );
  }
}

class UserProfileUpdateResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final UserProfileUpdateDataModel? data;

  UserProfileUpdateResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory UserProfileUpdateResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdateResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? UserProfileUpdateDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UserProfileUpdateDataModel {
  final String fullName;
  final String avatar;
  final double? height;
  final double? weight;
  final String? goal;

  UserProfileUpdateDataModel({
    required this.fullName,
    required this.avatar,
    this.height,
    this.weight,
    this.goal,
  });

  factory UserProfileUpdateDataModel.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdateDataModel(
      fullName: json['fullName'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      goal: json['goal'] as String?,
    );
  }
}
