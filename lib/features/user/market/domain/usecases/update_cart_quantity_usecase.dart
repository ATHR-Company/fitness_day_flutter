import 'package:fitness_day/core/network/api_result.dart';
import '../entities/cart_data.dart';
import '../repositories/cart_repository.dart';

class UpdateCartQuantityUseCase {
  final CartRepository repository;
  UpdateCartQuantityUseCase(this.repository);

  Future<ApiResult<CartData>> call(String itemIdentity, int quantity) =>
      repository.updateQuantity(itemIdentity, quantity);
}
