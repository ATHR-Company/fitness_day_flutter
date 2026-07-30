import 'package:fitness_day/core/network/api_result.dart';
import '../entities/order_counters_data.dart';
import '../repositories/checkout_repository.dart';

/// Badge counts for the cart and the unpaid-orders indicator.
///
/// Cheap by design, so it can run on every app open instead of pulling the
/// whole cart just to size a badge.
class GetOrderCountersUseCase {
  final CheckoutRepository repository;

  GetOrderCountersUseCase(this.repository);

  Future<ApiResult<OrderCountersData>> call() => repository.getCounters();
}
