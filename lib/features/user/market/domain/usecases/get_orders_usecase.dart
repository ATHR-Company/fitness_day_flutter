import 'package:fitness_day/core/network/api_result.dart';
import '../entities/order_data.dart';
import '../repositories/checkout_repository.dart';

class GetOrdersUseCase {
  final CheckoutRepository repository;

  GetOrdersUseCase(this.repository);

  /// [status] filters to `PENDING_PAYMENT`, `PAID` or `PAYMENT_FAILED`.
  Future<ApiResult<OrdersPageData>> call({
    int page = 1,
    int limit = 10,
    String? status,
  }) =>
      repository.getOrders(page: page, limit: limit, status: status);
}
