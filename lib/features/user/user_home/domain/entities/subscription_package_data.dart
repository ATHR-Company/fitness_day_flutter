class SubscriptionPackageData {
  final String imageUrl;
  final String name;
  final int currentPrice;
  final int oldPrice;
  final bool isFavorite;

  const SubscriptionPackageData({
    required this.imageUrl,
    required this.name,
    required this.currentPrice,
    required this.oldPrice,
    this.isFavorite = false,
  });
}
