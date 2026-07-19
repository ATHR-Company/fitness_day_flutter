class ProductDetail {
  final String title;
  final String description;
  final int order;

  const ProductDetail({
    required this.title,
    required this.description,
    required this.order,
  });
}

class ProductData {
  final String id;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double? oldPrice;
  final bool isFavorite;
  final String? discountTag;
  final String? offerTag;
  // Full details — only populated when fetched by ID
  final List<String> photos;
  final List<ProductDetail> details;

  ProductData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    this.oldPrice,
    this.isFavorite = false,
    this.discountTag,
    this.offerTag,
    this.photos = const [],
    this.details = const [],
  });
}
