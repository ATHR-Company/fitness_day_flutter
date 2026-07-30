import '../../domain/entities/payment_data.dart';

class PaymentInitiationModel {
  final String paymentIdentity;
  final String orderIdentity;
  final String status;
  final double amount;
  final String currency;
  final String webviewUrl;
  final String? clientSecret;
  final String? intentionId;
  final String? expiresAt;

  const PaymentInitiationModel({
    required this.paymentIdentity,
    required this.orderIdentity,
    required this.status,
    required this.amount,
    required this.currency,
    required this.webviewUrl,
    this.clientSecret,
    this.intentionId,
    this.expiresAt,
  });

  factory PaymentInitiationModel.fromJson(Map<String, dynamic> json) {
    return PaymentInitiationModel(
      paymentIdentity: json['paymentIdentity']?.toString() ?? '',
      orderIdentity: json['orderIdentity']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'SAR',
      webviewUrl: json['webviewUrl']?.toString() ?? '',
      clientSecret: json['clientSecret']?.toString(),
      intentionId: json['intentionId']?.toString(),
      expiresAt: json['expiresAt']?.toString(),
    );
  }

  PaymentInitiation toEntity() => PaymentInitiation(
        paymentIdentity: paymentIdentity,
        orderIdentity: orderIdentity,
        status: PaymentStatus.fromApi(status),
        amount: amount,
        currency: currency,
        webviewUrl: webviewUrl,
        clientSecret: clientSecret,
        intentionId: intentionId,
        expiresAt: DateTime.tryParse(expiresAt ?? ''),
      );
}

class PaymentStatusModel {
  final String paymentIdentity;
  final String orderIdentity;
  final String status;
  final double amount;
  final String currency;
  final String? paidAt;
  final String? failureReason;
  final String? expiresAt;

  const PaymentStatusModel({
    required this.paymentIdentity,
    required this.orderIdentity,
    required this.status,
    required this.amount,
    required this.currency,
    this.paidAt,
    this.failureReason,
    this.expiresAt,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      paymentIdentity: json['paymentIdentity']?.toString() ?? '',
      orderIdentity: json['orderIdentity']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'SAR',
      paidAt: json['paidAt']?.toString(),
      failureReason: json['failureReason']?.toString(),
      expiresAt: json['expiresAt']?.toString(),
    );
  }

  PaymentStatusData toEntity() => PaymentStatusData(
        paymentIdentity: paymentIdentity,
        orderIdentity: orderIdentity,
        status: PaymentStatus.fromApi(status),
        amount: amount,
        currency: currency,
        paidAt: DateTime.tryParse(paidAt ?? ''),
        failureReason: failureReason,
        expiresAt: DateTime.tryParse(expiresAt ?? ''),
      );
}
