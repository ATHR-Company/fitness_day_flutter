import '../../domain/entities/favorites_page_data.dart';
import '../../domain/entities/plans_data.dart';
import '../../domain/entities/store_home_data.dart';
import 'store_home_model.dart';

class FavoritesPageModel {
  final List<StoreProductItem> products;
  final List<PlanItem> plans;
  final int total;
  final int page;
  final int limit;

  FavoritesPageModel({
    required this.products,
    required this.plans,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory FavoritesPageModel.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>? ?? {};
    final list = outer['data'] as List? ?? [];

    // One array, two shapes: PRODUCT carries `mainPhoto` + `category`, PLAN
    // carries `coverPhoto`. Anything without an explicit PLAN marker is treated
    // as a product, which is also the safe default for an unknown itemType.
    final rawPlans = <dynamic>[];
    final rawProducts = <dynamic>[];
    for (final item in list) {
      if (item is! Map) continue;
      if (item['itemType'] == 'PLAN') {
        rawPlans.add(item);
      } else {
        rawProducts.add(item);
      }
    }

    return FavoritesPageModel(
      products: StoreHomeModel.parseProductsList(rawProducts),
      plans: rawPlans
          .map((e) => PlanItem(
                id: e['id'] ?? '',
                name: e['name'] ?? '',
                coverPhoto: e['coverPhoto'] ?? '',
                price: (e['price'] as num?)?.toDouble() ?? 0,
                compareAtPrice: (e['compareAtPrice'] as num?)?.toDouble(),
                badge: e['badge'] as String?,
                isFavorite: e['isFavorite'] ?? true,
              ))
          .toList(),
      total: outer['total'] as int? ?? 0,
      page: outer['page'] as int? ?? 1,
      limit: outer['limit'] as int? ?? 10,
    );
  }

  FavoritesPageData toEntity() {
    return FavoritesPageData(
      products: products,
      plans: plans,
      total: total,
      page: page,
      limit: limit,
    );
  }
}
