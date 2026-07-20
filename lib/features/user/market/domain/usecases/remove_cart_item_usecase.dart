import 'package:fitness_day/core/network/api_result.dart';
import '../entities/cart_data.dart';
import '../repositories/cart_repository.dart';

class RemoveCartItemUseCase {
  final CartRepository repository;
  RemoveCartItemUseCase(this.repository);

  Future<ApiResult<CartData>> call(String itemIdentity) =>
      repository.removeItem(itemIdentity);
}
