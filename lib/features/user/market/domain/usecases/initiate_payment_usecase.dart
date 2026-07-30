import 'package:fitness_day/core/network/api_result.dart';
import '../entities/payment_data.dart';
import '../repositories/payment_repository.dart';

/// Opens a Paymob checkout for an order that is still `PENDING_PAYMENT`.
///
/// Call this only after any coupon / delivery change has been applied — the
/// charged amount is locked server-side the moment this runs.
class InitiatePaymentUseCase {
  final PaymentRepository repository;

  InitiatePaymentUseCase(this.repository);

  Future<ApiResult<PaymentInitiation>> call(String orderIdentity) =>
      repository.initiate(orderIdentity);
}
