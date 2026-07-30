import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentInitiationModel> initiate(String orderIdentity);
  Future<PaymentStatusModel> getStatus(String orderIdentity);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiService apiService;

  PaymentRemoteDataSourceImpl(this.apiService);

  /// `POST /payments/paymob/orders/:id/initiate` — deliberately no body: the
  /// amount comes from the stored order, never from the app.
  ///
  /// Safe to call twice. If a checkout is still open at the same price the
  /// backend returns the same `webviewUrl`; if the total changed it cancels
  /// the old one and issues a fresh checkout.
  @override
  Future<PaymentInitiationModel> initiate(String orderIdentity) async {
    final response = await apiService.post(
      ApiEndpoints.initiatePaymobPayment(orderIdentity),
    );
    return PaymentInitiationModel.fromJson(
      response.data['data'] as Map<String, dynamic>? ?? {},
    );
  }

  /// `GET /payments/paymob/orders/:id/status` — the only source of truth for
  /// whether an order was actually paid.
  @override
  Future<PaymentStatusModel> getStatus(String orderIdentity) async {
    final response = await apiService.get(
      ApiEndpoints.paymobPaymentStatus(orderIdentity),
    );
    return PaymentStatusModel.fromJson(
      response.data['data'] as Map<String, dynamic>? ?? {},
    );
  }
}
