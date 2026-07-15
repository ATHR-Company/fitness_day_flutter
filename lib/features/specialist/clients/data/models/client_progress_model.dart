class ClientProgressResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final ClientProgressDataModel? data;
  final int? totalCount;
  final int? page;
  final int? totalPages;

  ClientProgressResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.totalCount,
    this.page,
    this.totalPages,
  });

  factory ClientProgressResponseModel.fromJson(Map<String, dynamic> json) {
    return ClientProgressResponseModel(
      success: json['success'] as bool?,
      statusCode: json['statusCode'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? ClientProgressDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      totalCount: json['totalCount'] as int?,
      page: json['page'] as int?,
      totalPages: json['totalPages'] as int?,
    );
  }
}

class ClientProgressDataModel {
  final ClientProgressMeasurementModel? currentWeight;
  final List<ClientProgressChartPointModel>? chart;
  final ClientProgressVisitModel? visit;

  ClientProgressDataModel({this.currentWeight, this.chart, this.visit});

  factory ClientProgressDataModel.fromJson(Map<String, dynamic> json) {
    return ClientProgressDataModel(
      currentWeight: json['currentWeight'] != null
          ? ClientProgressMeasurementModel.fromJson(json['currentWeight'] as Map<String, dynamic>)
          : null,
      chart: (json['chart'] as List<dynamic>?)
          ?.map((e) => ClientProgressChartPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      visit: json['visit'] != null
          ? ClientProgressVisitModel.fromJson(json['visit'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ClientProgressMeasurementModel {
  final double? value;
  final String? unit;

  ClientProgressMeasurementModel({this.value, this.unit});

  factory ClientProgressMeasurementModel.fromJson(Map<String, dynamic> json) {
    return ClientProgressMeasurementModel(
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );
  }
}

class ClientProgressChartPointModel {
  final int? visitNumber;
  final String? weekStart;
  final double? weight;

  ClientProgressChartPointModel({this.visitNumber, this.weekStart, this.weight});

  factory ClientProgressChartPointModel.fromJson(Map<String, dynamic> json) {
    return ClientProgressChartPointModel(
      visitNumber: json['visitNumber'] as int?,
      weekStart: json['weekStart'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }
}

class ClientProgressVisitModel {
  final int? visitNumber;
  final String? weekStart;
  final ClientProgressMeasurementModel? weight;
  final ClientProgressMeasurementModel? height;
  final ClientProgressMeasurementModel? idealWeight;
  final ClientProgressMeasurementModel? bmi;

  ClientProgressVisitModel({
    this.visitNumber,
    this.weekStart,
    this.weight,
    this.height,
    this.idealWeight,
    this.bmi,
  });

  factory ClientProgressVisitModel.fromJson(Map<String, dynamic> json) {
    return ClientProgressVisitModel(
      visitNumber: json['visitNumber'] as int?,
      weekStart: json['weekStart'] as String?,
      weight: json['weight'] != null
          ? ClientProgressMeasurementModel.fromJson(json['weight'] as Map<String, dynamic>)
          : null,
      height: json['height'] != null
          ? ClientProgressMeasurementModel.fromJson(json['height'] as Map<String, dynamic>)
          : null,
      idealWeight: json['idealWeight'] != null
          ? ClientProgressMeasurementModel.fromJson(json['idealWeight'] as Map<String, dynamic>)
          : null,
      bmi: json['bmi'] != null
          ? ClientProgressMeasurementModel.fromJson(json['bmi'] as Map<String, dynamic>)
          : null,
    );
  }
}
