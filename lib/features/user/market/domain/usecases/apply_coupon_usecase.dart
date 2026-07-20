import 'package:fitness_day/core/network/api_result.dart';
import '../entities/order_data.dart';
import '../repositories/checkout_repository.dart';

class ApplyCouponUseCase {
  final CheckoutRepository repository;

  ApplyCouponUseCase(this.repository);

  Future<ApiResult<OrderData>> call({
    required String orderIdentity,
    required String? couponCode,
  }) =>
      repository.applyCoupon(
        orderIdentity: orderIdentity,
        couponCode: couponCode,
      );
}
