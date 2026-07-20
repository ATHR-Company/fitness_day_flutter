import 'package:dio/dio.dart';
import 'package:fitness_day/core/errors/failures.dart';
import 'package:fitness_day/core/network/api_result.dart';
import '../../domain/entities/cart_data.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<CartData>> getCart() async {
    try {
      final model = await remoteDataSource.getCart();
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(_messageOf(e, 'Failed to load cart')));
    }
  }

  @override
  Future<ApiResult<CartData>> addToCart(CartItemInput input) async {
    try {
      final model = await remoteDataSource.addToCart(input);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(
          ServerFailure(_messageOf(e, 'Failed to add item to cart')));
    }
  }

  @override
  Future<ApiResult<CartData>> updateQuantity(
      String itemIdentity, int quantity) async {
    try {
      final model =
          await remoteDataSource.updateQuantity(itemIdentity, quantity);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(
          ServerFailure(_messageOf(e, 'Failed to update quantity')));
    }
  }

  @override
  Future<ApiResult<CartData>> removeItem(String itemIdentity) async {
    try {
      final model = await remoteDataSource.removeItem(itemIdentity);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(
          ServerFailure(_messageOf(e, 'Failed to remove item')));
    }
  }

  /// Prefer the backend's already-localized `message` (per the `lang` header)
  /// so cart errors like "out of stock" show verbatim; fall back otherwise.
  String _messageOf(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
    }
    return fallback;
  }
}
