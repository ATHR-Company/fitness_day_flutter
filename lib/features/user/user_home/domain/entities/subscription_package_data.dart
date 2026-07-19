class SubscriptionPackageData {
  final String id;
  final String imageUrl;
  final String name;
  final int currentPrice;
  final int oldPrice;
  final bool isFavorite;

  const SubscriptionPackageData({
    this.id = '',
    required this.imageUrl,
    required this.name,
    required this.currentPrice,
    required this.oldPrice,
    this.isFavorite = false,
  });
}
