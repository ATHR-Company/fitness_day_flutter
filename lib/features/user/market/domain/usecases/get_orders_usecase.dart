import 'package:fitness_day/core/network/api_result.dart';
import '../entities/order_data.dart';
import '../repositories/checkout_repository.dart';

class GetOrdersUseCase {
  final CheckoutRepository repository;

  GetOrdersUseCase(this.repository);

  Future<ApiResult<List<OrderData>>> call() => repository.getOrders();
}
