class CompleteWorkoutSetData {
  final int totalSets;
  final int completedSets;
  final bool isCompleted;

  const CompleteWorkoutSetData({
    required this.totalSets,
    required this.completedSets,
    required this.isCompleted,
  });

  factory CompleteWorkoutSetData.fromJson(Map<String, dynamic> json) {
    return CompleteWorkoutSetData(
      totalSets: json['totalSets'] as int? ?? 0,
      completedSets: json['completedSets'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSets': totalSets,
      'completedSets': completedSets,
      'isCompleted': isCompleted,
    };
  }
}

class CompleteWorkoutSetResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final CompleteWorkoutSetData? data;

  const CompleteWorkoutSetResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory CompleteWorkoutSetResponseModel.fromJson(Map<String, dynamic> json) {
    return CompleteWorkoutSetResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? CompleteWorkoutSetData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
      'data': data?.toJson(),
    };
  }
}
