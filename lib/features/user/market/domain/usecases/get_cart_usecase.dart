import 'package:fitness_day/core/network/api_result.dart';
import '../entities/cart_data.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository repository;
  GetCartUseCase(this.repository);

  Future<ApiResult<CartData>> call() => repository.getCart();
}
