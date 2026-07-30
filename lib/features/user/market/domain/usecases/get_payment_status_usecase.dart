import 'package:fitness_day/core/network/api_result.dart';
import '../entities/payment_data.dart';
import '../repositories/payment_repository.dart';

/// Asks the backend what actually happened to a payment.
///
/// This is the only thing that may unlock a success screen — the Paymob page
/// showing "success" proves nothing, since only the backend receives Paymob's
/// signed server-to-server callback.
class GetPaymentStatusUseCase {
  final PaymentRepository repository;

  GetPaymentStatusUseCase(this.repository);

  Future<ApiResult<PaymentStatusData>> call(String orderIdentity) =>
      repository.getStatus(orderIdentity);
}
