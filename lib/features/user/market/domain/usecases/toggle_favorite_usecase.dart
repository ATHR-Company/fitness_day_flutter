import 'package:fitness_day/core/network/api_result.dart';
import '../repositories/market_repository.dart';

class ToggleFavoriteUseCase {
  final MarketRepository repository;

  ToggleFavoriteUseCase(this.repository);

  /// Returns the new [isFavorite] value.
  Future<ApiResult<bool>> call(String productIdentity) =>
      repository.toggleFavorite(productIdentity);
}
