import 'package:fitness_day/core/network/api_result.dart';
import '../../domain/entities/cart_data.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';
import 'package:fitness_day/core/errors/error_handler.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<CartData>> getCart() async {
    try {
      final model = await remoteDataSource.getCart();
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<CartData>> addToCart(CartItemInput input) async {
    try {
      final model = await remoteDataSource.addToCart(input);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
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
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<CartData>> removeItem(String itemIdentity) async {
    try {
      final model = await remoteDataSource.removeItem(itemIdentity);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

}
