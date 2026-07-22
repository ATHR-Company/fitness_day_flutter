import 'package:fitness_day/core/network/api_result.dart';
import '../entities/cart_data.dart';
import '../repositories/market_repository.dart';

class ToggleFavoriteUseCase {
  final MarketRepository repository;

  ToggleFavoriteUseCase(this.repository);

  /// Toggles the favourite flag for a product or a plan and returns the new
  /// [isFavorite] value as reported by the server.
  Future<ApiResult<bool>> call({
    required CartItemType itemType,
    required String itemIdentity,
  }) =>
      repository.toggleFavorite(itemType: itemType, itemIdentity: itemIdentity);
}
