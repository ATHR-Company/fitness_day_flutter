class ClientAssessmentsResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final List<ClientAssessmentModel>? data;
  final int? totalCount;
  final int? page;
  final int? totalPages;

  ClientAssessmentsResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.totalCount,
    this.page,
    this.totalPages,
  });

  factory ClientAssessmentsResponseModel.fromJson(Map<String, dynamic> json) {
    return ClientAssessmentsResponseModel(
      success: json['success'] as bool?,
      statusCode: json['statusCode'] as int?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ClientAssessmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int?,
      page: json['page'] as int?,
      totalPages: json['totalPages'] as int?,
    );
  }
}

class ClientAssessmentModel {
  final ClientAssessmentUserModel? user;
  final String? assessmentId;
  final String? name;
  final String? description;
  final String? image;
  final String? placement;
  final String? weekStart;
  final bool? isNew;

  ClientAssessmentModel({
    this.user,
    this.assessmentId,
    this.name,
    this.description,
    this.image,
    this.placement,
    this.weekStart,
    this.isNew,
  });

  factory ClientAssessmentModel.fromJson(Map<String, dynamic> json) {
    return ClientAssessmentModel(
      user: json['user'] != null
          ? ClientAssessmentUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      assessmentId: json['assessmentId'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      placement: json['placement'] as String?,
      weekStart: json['weekStart'] as String?,
      isNew: json['isNew'] as bool?,
    );
  }
}

class ClientAssessmentUserModel {
  final String? id;
  final String? name;
  final double? adherenceRate;

  ClientAssessmentUserModel({
    this.id,
    this.name,
    this.adherenceRate,
  });

  factory ClientAssessmentUserModel.fromJson(Map<String, dynamic> json) {
    return ClientAssessmentUserModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      adherenceRate: (json['adherenceRate'] as num?)?.toDouble(),
    );
  }
}
