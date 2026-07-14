class UpdateMealCompletionData {
  final String mealId;
  final bool isCompleted;

  const UpdateMealCompletionData({
    required this.mealId,
    required this.isCompleted,
  });

  factory UpdateMealCompletionData.fromJson(Map<String, dynamic> json) {
    return UpdateMealCompletionData(
      mealId: json['mealId'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealId': mealId,
      'isCompleted': isCompleted,
    };
  }
}

class UpdateMealCompletionResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final UpdateMealCompletionData? data;

  const UpdateMealCompletionResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory UpdateMealCompletionResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateMealCompletionResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? UpdateMealCompletionData.fromJson(json['data'] as Map<String, dynamic>)
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
