import 'package:fitness_day/core/network/api_result.dart';
import '../entities/products_page_data.dart';
import '../repositories/market_repository.dart';

class GetProductsUseCase {
  final MarketRepository repository;

  GetProductsUseCase(this.repository);

  Future<ApiResult<ProductsPageData>> call({
    required ProductsFilter filter,
    int page = 1,
    int limit = 10,
  }) =>
      repository.getProducts(filter: filter, page: page, limit: limit);
}
