class SpecialistUpdateClientNotesResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistUpdateClientNotesDataModel? data;

  SpecialistUpdateClientNotesResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistUpdateClientNotesResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistUpdateClientNotesResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistUpdateClientNotesDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistUpdateClientNotesDataModel {
  final String assessmentId;
  final String clientNotes;

  SpecialistUpdateClientNotesDataModel({
    required this.assessmentId,
    required this.clientNotes,
  });

  factory SpecialistUpdateClientNotesDataModel.fromJson(Map<String, dynamic> json) {
    return SpecialistUpdateClientNotesDataModel(
      assessmentId: json['assessmentId'] as String? ?? '',
      clientNotes: json['clientNotes'] as String? ?? '',
    );
  }
}
