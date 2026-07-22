import 'plans_data.dart';
import 'store_home_data.dart';

/// A page of the user's favourites.
///
/// The endpoint returns products and plans interleaved in a single array,
/// discriminated by `itemType`. They are split apart here because the two are
/// rendered by different cards with different grid metrics — keeping them in
/// one list would force a mixed-height grid for no benefit.
class FavoritesPageData {
  final List<StoreProductItem> products;
  final List<PlanItem> plans;
  final int total;
  final int page;
  final int limit;

  const FavoritesPageData({
    required this.products,
    required this.plans,
    required this.total,
    required this.page,
    required this.limit,
  });

  bool get isEmpty => products.isEmpty && plans.isEmpty;

  bool get hasMore => (page * limit) < total;
}
