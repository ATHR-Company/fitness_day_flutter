// ── CLIENTS LIST API MODELS ─────────────────────────────────────────────────

class SpecialistClientsListResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final List<SpecialistClientListItemModel>? data;
  final int? totalCount;
  final int? page;
  final int? totalPages;

  SpecialistClientsListResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.totalCount,
    this.page,
    this.totalPages,
  });

  factory SpecialistClientsListResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistClientsListResponseModel(
      success: json['success'] as bool?,
      statusCode: json['statusCode'] as int?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SpecialistClientListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int?,
      page: json['page'] as int?,
      totalPages: json['totalPages'] as int?,
    );
  }
}

class SpecialistClientListItemModel {
  final SpecialistClientUserMinModel? user;
  final double? adherenceRate;
  final double? currentWeight;
  final String? goal;
  final String? lastAppointment;
  final bool? isSubscribed;

  SpecialistClientListItemModel({
    this.user,
    this.adherenceRate,
    this.currentWeight,
    this.goal,
    this.lastAppointment,
    this.isSubscribed,
  });

  factory SpecialistClientListItemModel.fromJson(Map<String, dynamic> json) {
    return SpecialistClientListItemModel(
      user: json['user'] != null
          ? SpecialistClientUserMinModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      adherenceRate: (json['adherenceRate'] as num?)?.toDouble(),
      currentWeight: (json['currentWeight'] as num?)?.toDouble(),
      goal: json['goal'] as String?,
      lastAppointment: json['lastAppointment'] as String?,
      isSubscribed: json['isSubscribed'] as bool?,
    );
  }
}

class SpecialistClientUserMinModel {
  final String? id;
  final String? name;
  final String? image;

  SpecialistClientUserMinModel({
    this.id,
    this.name,
    this.image,
  });

  factory SpecialistClientUserMinModel.fromJson(Map<String, dynamic> json) {
    return SpecialistClientUserMinModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
    );
  }
}

// ── CLIENT PROFILE DETAILS API MODELS ────────────────────────────────────────

class SpecialistClientProfileResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final SpecialistClientProfileDataModel? data;

  SpecialistClientProfileResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory SpecialistClientProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistClientProfileResponseModel(
      success: json['success'] as bool?,
      statusCode: json['statusCode'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? SpecialistClientProfileDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistClientProfileDataModel {
  final SpecialistUserDataModel? userData;
  final SpecialistBodyReportModel? bodyReport;
  final List<SpecialistHealthQuestionModel>? healthQuestions;

  SpecialistClientProfileDataModel({
    this.userData,
    this.bodyReport,
    this.healthQuestions,
  });

  factory SpecialistClientProfileDataModel.fromJson(Map<String, dynamic> json) {
    return SpecialistClientProfileDataModel(
      userData: json['userData'] != null
          ? SpecialistUserDataModel.fromJson(json['userData'] as Map<String, dynamic>)
          : null,
      bodyReport: json['bodyReport'] != null
          ? SpecialistBodyReportModel.fromJson(json['bodyReport'] as Map<String, dynamic>)
          : null,
      healthQuestions: (json['healthQuestions'] as List<dynamic>?)
          ?.map((e) => SpecialistHealthQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SpecialistUserDataModel {
  final String? id;

  /// Existing conversation with this client, or `null` when they have never
  /// chatted. Null is not an error: opening the chat with the client's [id]
  /// creates the conversation on the spot.
  final String? conversationId;

  final String? fullName;
  final String? avatar;
  final int? age;
  final double? height;
  final double? weight;
  final String? activityLevel;
  final String? goal;
  final double? adherenceRate;

  SpecialistUserDataModel({
    this.id,
    this.conversationId,
    this.fullName,
    this.avatar,
    this.age,
    this.height,
    this.weight,
    this.activityLevel,
    this.goal,
    this.adherenceRate,
  });

  factory SpecialistUserDataModel.fromJson(Map<String, dynamic> json) {
    return SpecialistUserDataModel(
      id: json['id'] as String?,
      conversationId: json['conversationId'] as String?,
      fullName: json['fullName'] as String?,
      avatar: json['avatar'] as String?,
      age: json['age'] as int?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      activityLevel: json['activityLevel'] as String?,
      goal: json['goal'] as String?,
      adherenceRate: (json['adherenceRate'] as num?)?.toDouble(),
    );
  }
}

class SpecialistBodyReportModel {
  final SpecialistBmiModel? bmi;
  final SpecialistIdealWeightModel? idealWeight;
  final SpecialistCaloriesModel? calories;
  final SpecialistProteinNeedsModel? proteinNeeds;

  SpecialistBodyReportModel({
    this.bmi,
    this.idealWeight,
    this.calories,
    this.proteinNeeds,
  });

  factory SpecialistBodyReportModel.fromJson(Map<String, dynamic> json) {
    return SpecialistBodyReportModel(
      bmi: json['bmi'] != null ? SpecialistBmiModel.fromJson(json['bmi'] as Map<String, dynamic>) : null,
      idealWeight: json['idealWeight'] != null
          ? SpecialistIdealWeightModel.fromJson(json['idealWeight'] as Map<String, dynamic>)
          : null,
      calories: json['calories'] != null
          ? SpecialistCaloriesModel.fromJson(json['calories'] as Map<String, dynamic>)
          : null,
      proteinNeeds: json['proteinNeeds'] != null
          ? SpecialistProteinNeedsModel.fromJson(json['proteinNeeds'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistBmiModel {
  final double? value;
  final String? status;
  final String? unit;

  SpecialistBmiModel({this.value, this.status, this.unit});

  factory SpecialistBmiModel.fromJson(Map<String, dynamic> json) {
    return SpecialistBmiModel(
      value: (json['value'] as num?)?.toDouble(),
      status: json['status'] as String?,
      unit: json['unit'] as String?,
    );
  }
}

class SpecialistIdealWeightModel {
  final double? value;
  final String? unit;

  SpecialistIdealWeightModel({this.value, this.unit});

  factory SpecialistIdealWeightModel.fromJson(Map<String, dynamic> json) {
    return SpecialistIdealWeightModel(
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );
  }
}

class SpecialistCaloriesModel {
  final double? value;
  final String? unit;

  SpecialistCaloriesModel({this.value, this.unit});

  factory SpecialistCaloriesModel.fromJson(Map<String, dynamic> json) {
    return SpecialistCaloriesModel(
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );
  }
}

class SpecialistProteinNeedsModel {
  final double? value;
  final String? unit;

  SpecialistProteinNeedsModel({this.value, this.unit});

  factory SpecialistProteinNeedsModel.fromJson(Map<String, dynamic> json) {
    return SpecialistProteinNeedsModel(
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );
  }
}

class SpecialistHealthQuestionModel {
  final String? question;
  final bool? answer;
  final String? details;

  SpecialistHealthQuestionModel({this.question, this.answer, this.details});

  factory SpecialistHealthQuestionModel.fromJson(Map<String, dynamic> json) {
    return SpecialistHealthQuestionModel(
      question: json['question'] as String?,
      answer: json['answer'] as bool?,
      details: json['details'] as String?,
    );
  }
}
