class SpecialistProfileResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistProfileDataModel? data;

  SpecialistProfileResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistProfileResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistProfileDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistProfileDataModel {
  final String id;
  final String name;
  final String avatar;

  SpecialistProfileDataModel({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory SpecialistProfileDataModel.fromJson(Map<String, dynamic> json) {
    return SpecialistProfileDataModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
    );
  }
}
