import 'store_home_data.dart';

/// Describes how to fetch a products list — either by type or by category.
class ProductsFilter {
  /// e.g. 'BEST_OFFERS', 'NEW_PRODUCTS', 'BEST_SELLERS'. Null when using [categoryId].
  final String? type;

  /// Category ID. Null when using [type].
  final String? categoryId;

  const ProductsFilter.byType(String this.type) : categoryId = null;
  const ProductsFilter.byCategory(String this.categoryId) : type = null;
}

class ProductsPageData {
  final List<StoreProductItem> products;
  final int total;
  final int page;
  final int limit;

  const ProductsPageData({
    required this.products,
    required this.total,
    required this.page,
    required this.limit,
  });

  bool get hasMore => (page * limit) < total;
}
