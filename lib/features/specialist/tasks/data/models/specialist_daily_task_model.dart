class SpecialistDailyTasksResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final List<SpecialistDailyTaskItemModel> data;
  final int totalCount;
  final int page;
  final int totalPages;

  SpecialistDailyTasksResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  factory SpecialistDailyTasksResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistDailyTasksResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => SpecialistDailyTaskItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class SpecialistDailyTaskItemModel {
  final SpecialistDailyTaskUserModel? user;
  final String assessmentId;
  final String name;
  final String description;
  final String image;
  final String placement;
  final String weekStart;
  final bool isNew;

  SpecialistDailyTaskItemModel({
    this.user,
    required this.assessmentId,
    required this.name,
    required this.description,
    required this.image,
    required this.placement,
    required this.weekStart,
    required this.isNew,
  });

  factory SpecialistDailyTaskItemModel.fromJson(Map<String, dynamic> json) {
    return SpecialistDailyTaskItemModel(
      user: json['user'] != null
          ? SpecialistDailyTaskUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      assessmentId: json['assessmentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      placement: json['placement'] as String? ?? '',
      weekStart: json['weekStart'] as String? ?? '',
      isNew: json['isNew'] as bool? ?? false,
    );
  }
}

class SpecialistDailyTaskUserModel {
  final String id;
  final String name;
  final double adherenceRate;

  SpecialistDailyTaskUserModel({
    required this.id,
    required this.name,
    required this.adherenceRate,
  });

  factory SpecialistDailyTaskUserModel.fromJson(Map<String, dynamic> json) {
    return SpecialistDailyTaskUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      adherenceRate: (json['adherenceRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
