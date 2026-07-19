class BannerItem {
  final String id;
  final String photo;
  final int order;

  const BannerItem({
    required this.id,
    required this.photo,
    required this.order,
  });
}

class CategoryItem {
  final String id;
  final String name;

  const CategoryItem({required this.id, required this.name});
}

class StoreProductItem {
  final String id;
  final String name;
  final String mainPhoto;
  final double price;
  final double? compareAtPrice;
  final String? badge;
  final CategoryItem? category;
  final bool isFavorite;

  const StoreProductItem({
    required this.id,
    required this.name,
    required this.mainPhoto,
    required this.price,
    this.compareAtPrice,
    this.badge,
    this.category,
    this.isFavorite = false,
  });
}

class StoreHomeData {
  final List<BannerItem> headerBanners;
  final List<BannerItem> middleBanners;
  final List<CategoryItem> categories;
  final List<StoreProductItem> bestOffers;
  final List<StoreProductItem> newProducts;
  final List<StoreProductItem> bestSellers;

  const StoreHomeData({
    required this.headerBanners,
    required this.middleBanners,
    required this.categories,
    required this.bestOffers,
    required this.newProducts,
    required this.bestSellers,
  });
}
