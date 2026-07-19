import '../../domain/entities/store_home_data.dart';

class StoreHomeModel {
  final List<BannerItem> headerBanners;
  final List<BannerItem> middleBanners;
  final List<CategoryItem> categories;
  final List<StoreProductItem> bestOffers;
  final List<StoreProductItem> newProducts;
  final List<StoreProductItem> bestSellers;

  StoreHomeModel({
    required this.headerBanners,
    required this.middleBanners,
    required this.categories,
    required this.bestOffers,
    required this.newProducts,
    required this.bestSellers,
  });

  factory StoreHomeModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final banners = data['banners'] as Map<String, dynamic>? ?? {};

    return StoreHomeModel(
      headerBanners: _parseBanners(banners['header']),
      middleBanners: _parseBanners(banners['middle']),
      categories: _parseCategories(data['categories']),
      bestOffers: _parseProducts(data['bestOffers']),
      newProducts: _parseProducts(data['newProducts']),
      bestSellers: _parseProducts(data['bestSellers']),
    );
  }

  static List<BannerItem> _parseBanners(dynamic list) {
    if (list == null) return [];
    return (list as List).map((e) {
      return BannerItem(
        id: e['id'] ?? '',
        photo: e['photo'] ?? '',
        order: e['order'] ?? 0,
      );
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  static List<CategoryItem> _parseCategories(dynamic list) {
    if (list == null) return [];
    return (list as List).map((e) {
      return CategoryItem(
        id: e['id'] ?? '',
        name: e['name'] ?? '',
      );
    }).toList();
  }

  static List<StoreProductItem> _parseProducts(dynamic list) {
    if (list == null) return [];
    return parseProductsList(list as List);
  }

  /// Public helper — reused by [ProductsPageModel].
  static List<StoreProductItem> parseProductsList(List<dynamic> list) {
    return list.map((e) {
      final cat = e['category'] as Map<String, dynamic>?;
      return StoreProductItem(
        id: e['id'] ?? '',
        name: e['name'] ?? '',
        mainPhoto: e['mainPhoto'] ?? '',
        price: (e['price'] as num?)?.toDouble() ?? 0,
        compareAtPrice: (e['compareAtPrice'] as num?)?.toDouble(),
        badge: e['badge'] as String?,
        category: cat != null
            ? CategoryItem(id: cat['id'] ?? '', name: cat['name'] ?? '')
            : null,
        isFavorite: e['isFavorite'] ?? false,
      );
    }).toList();
  }

  StoreHomeData toEntity() {
    return StoreHomeData(
      headerBanners: headerBanners,
      middleBanners: middleBanners,
      categories: categories,
      bestOffers: bestOffers,
      newProducts: newProducts,
      bestSellers: bestSellers,
    );
  }
}
