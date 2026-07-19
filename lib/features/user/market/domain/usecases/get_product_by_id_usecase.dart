import 'package:fitness_day/core/network/api_result.dart';
import '../entities/product_data.dart';
import '../repositories/market_repository.dart';

class GetProductByIdUseCase {
  final MarketRepository repository;

  GetProductByIdUseCase(this.repository);

  Future<ApiResult<ProductData>> call(String id) => repository.getProductById(id);
}
