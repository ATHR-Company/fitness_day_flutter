import 'package:fitness_day/core/network/api_result.dart';
import '../entities/cart_data.dart';

abstract class CartRepository {
  Future<ApiResult<CartData>> getCart();
  Future<ApiResult<CartData>> addToCart(CartItemInput input);
  Future<ApiResult<CartData>> updateQuantity(String itemIdentity, int quantity);
  Future<ApiResult<CartData>> removeItem(String itemIdentity);
}
