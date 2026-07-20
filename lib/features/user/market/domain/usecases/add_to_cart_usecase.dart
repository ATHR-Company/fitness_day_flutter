import 'package:fitness_day/core/network/api_result.dart';
import '../entities/cart_data.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;
  AddToCartUseCase(this.repository);

  Future<ApiResult<CartData>> call(CartItemInput input) =>
      repository.addToCart(input);
}
