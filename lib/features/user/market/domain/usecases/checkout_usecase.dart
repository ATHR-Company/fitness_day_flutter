import 'package:fitness_day/core/network/api_result.dart';
import '../entities/order_data.dart';
import '../repositories/checkout_repository.dart';

class CheckoutUseCase {
  final CheckoutRepository repository;
  CheckoutUseCase(this.repository);

  Future<ApiResult<OrderData>> call(CheckoutInput input) =>
      repository.checkout(input);
}
