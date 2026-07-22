import 'package:fitness_day/core/network/api_result.dart';
import '../entities/favorites_page_data.dart';
import '../repositories/market_repository.dart';

class GetFavoritesUseCase {
  final MarketRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<ApiResult<FavoritesPageData>> call({int page = 1, int limit = 10}) =>
      repository.getFavorites(page: page, limit: limit);
}
