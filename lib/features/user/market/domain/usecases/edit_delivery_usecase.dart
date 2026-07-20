import 'package:fitness_day/core/network/api_result.dart';
import '../entities/order_data.dart';
import '../repositories/checkout_repository.dart';

class EditDeliveryUseCase {
  final CheckoutRepository repository;
  EditDeliveryUseCase(this.repository);

  Future<ApiResult<OrderData>> call({
    required String orderIdentity,
    required String deliveryMethod,
  }) =>
      repository.editDelivery(
        orderIdentity: orderIdentity,
        deliveryMethod: deliveryMethod,
      );
}
