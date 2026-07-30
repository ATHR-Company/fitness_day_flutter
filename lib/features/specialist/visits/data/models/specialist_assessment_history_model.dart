class SpecialistAssessmentHistoryResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final List<SpecialistAssessmentHistoryItemModel> data;
  final int totalCount;
  final int page;
  final int totalPages;

  SpecialistAssessmentHistoryResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  factory SpecialistAssessmentHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistAssessmentHistoryResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => SpecialistAssessmentHistoryItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class SpecialistAssessmentHistoryItemModel {
  final SpecialistAssessmentHistoryUserModel? user;

  /// Existing conversation with this client, or `null` when there is none yet —
  /// the chat screen creates one from `user.id` in that case.
  final String? conversationId;

  final String assessmentId;
  final String name;
  final String description;
  final String image;
  final String placement;
  final String weekStart;
  final double? adherenceRate;
  final String? goal;
  final bool isNew;
  final bool isStarted;

  SpecialistAssessmentHistoryItemModel({
    this.user,
    this.conversationId,
    required this.assessmentId,
    required this.name,
    required this.description,
    required this.image,
    required this.placement,
    required this.weekStart,
    this.adherenceRate,
    this.goal,
    required this.isNew,
    required this.isStarted,
  });

  factory SpecialistAssessmentHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return SpecialistAssessmentHistoryItemModel(
      user: json['user'] != null
          ? SpecialistAssessmentHistoryUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      conversationId: json['conversationId'] as String?,
      assessmentId: json['assessmentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      placement: json['placement'] as String? ?? '',
      weekStart: json['weekStart'] as String? ?? '',
      adherenceRate: (json['adherenceRate'] as num?)?.toDouble(),
      goal: json['goal'] as String?,
      isNew: json['isNew'] as bool? ?? false,
      isStarted: json['isStarted'] as bool? ?? false,
    );
  }
}

class SpecialistAssessmentHistoryUserModel {
  final String id;
  final String name;

  SpecialistAssessmentHistoryUserModel({
    required this.id,
    required this.name,
  });

  factory SpecialistAssessmentHistoryUserModel.fromJson(Map<String, dynamic> json) {
    return SpecialistAssessmentHistoryUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
