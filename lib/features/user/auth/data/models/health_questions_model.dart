class HealthQuestion {
  final String id;
  final String text;
  final int order;

  const HealthQuestion({
    required this.id,
    required this.text,
    required this.order,
  });

  factory HealthQuestion.fromJson(Map<String, dynamic> json) {
    return HealthQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      order: json['order'] as int? ?? 0,
    );
  }
}

class HealthQuestionsResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final List<HealthQuestion> data;

  const HealthQuestionsResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory HealthQuestionsResponseModel.fromJson(Map<String, dynamic> json) {
    final questionsList = (json['data'] as List? ?? [])
        .map((e) => HealthQuestion.fromJson(e as Map<String, dynamic>))
        .toList();

    return HealthQuestionsResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: questionsList,
    );
  }
}
