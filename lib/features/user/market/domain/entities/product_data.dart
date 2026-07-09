class ProductData {
  final String id;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double? oldPrice;
  final bool isFavorite;
  final String? discountTag; // e.g. "50% لفترة محدودة"
  final String? offerTag;    // e.g. "حبة + حبة مجاناً"

  ProductData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    this.oldPrice,
    this.isFavorite = false,
    this.discountTag,
    this.offerTag,
  });
}
