import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import '../../domain/entities/cart_data.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addToCart(CartItemInput input);
  Future<CartModel> updateQuantity(String itemIdentity, int quantity);
  Future<CartModel> removeItem(String itemIdentity);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiService apiService;

  CartRemoteDataSourceImpl(this.apiService);

  @override
  Future<CartModel> getCart() async {
    final response = await apiService.get(ApiEndpoints.cart);
    return CartModel.fromJson(
      response.data['data'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<CartModel> addToCart(CartItemInput input) async {
    final response = await apiService.post(
      ApiEndpoints.cart,
      data: {
        'itemType': input.itemType.apiValue,
        'itemIdentity': input.itemIdentity,
        'quantity': input.quantity,
      },
    );
    return CartModel.fromJson(
      response.data['data'] as Map<String, dynamic>? ?? {},
    );
  }

  // Confirmed: PATCH /cart/items/:itemIdentity, body { quantity } (absolute).
  @override
  Future<CartModel> updateQuantity(String itemIdentity, int quantity) async {
    final response = await apiService.patch(
      ApiEndpoints.cartItem(itemIdentity),
      data: {'quantity': quantity},
    );
    return CartModel.fromJson(
      response.data['data'] as Map<String, dynamic>? ?? {},
    );
  }

  // Confirmed: DELETE /cart/items/:itemIdentity (no body).
  @override
  Future<CartModel> removeItem(String itemIdentity) async {
    final response =
        await apiService.delete(ApiEndpoints.cartItem(itemIdentity));
    return CartModel.fromJson(
      response.data['data'] as Map<String, dynamic>? ?? {},
    );
  }
}
