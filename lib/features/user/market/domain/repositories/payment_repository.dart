import 'package:fitness_day/core/network/api_result.dart';
import '../entities/payment_data.dart';

abstract class PaymentRepository {
  /// Opens (or reuses) a Paymob checkout for [orderIdentity].
  Future<ApiResult<PaymentInitiation>> initiate(String orderIdentity);

  /// The authoritative result of the payment. Nothing else may be trusted.
  Future<ApiResult<PaymentStatusData>> getStatus(String orderIdentity);
}
