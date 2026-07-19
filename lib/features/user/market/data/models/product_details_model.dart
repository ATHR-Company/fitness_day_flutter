import '../../domain/entities/product_data.dart';
import '../../domain/entities/store_home_data.dart';

class ProductDetailsModel {
  final String id;
  final String name;
  final String mainPhoto;
  final List<String> photos;
  final CategoryItem? category;
  final double price;
  final double? compareAtPrice;
  final String? badge;
  final List<ProductDetail> details;
  final bool isFavorite;

  ProductDetailsModel({
    required this.id,
    required this.name,
    required this.mainPhoto,
    required this.photos,
    this.category,
    required this.price,
    this.compareAtPrice,
    this.badge,
    required this.details,
    this.isFavorite = false,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final cat = data['category'] as Map<String, dynamic>?;
    final rawPhotos = data['photos'] as List? ?? [];
    final rawDetails = data['details'] as List? ?? [];

    final parsedDetails = rawDetails.map((e) {
      return ProductDetail(
        title: e['title'] ?? '',
        description: e['description'] ?? '',
        order: e['order'] ?? 0,
      );
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return ProductDetailsModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      mainPhoto: data['mainPhoto'] ?? '',
      photos: rawPhotos.map((e) => e.toString()).toList(),
      category: cat != null
          ? CategoryItem(id: cat['id'] ?? '', name: cat['name'] ?? '')
          : null,
      price: (data['price'] as num?)?.toDouble() ?? 0,
      compareAtPrice: (data['compareAtPrice'] as num?)?.toDouble(),
      badge: data['badge'] as String?,
      details: parsedDetails,
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  ProductData toEntity() {
    return ProductData(
      id: id,
      name: name,
      imageUrl: mainPhoto,
      currentPrice: price,
      oldPrice: compareAtPrice,
      isFavorite: isFavorite,
      discountTag: badge,
      photos: photos,
      details: details,
    );
  }
}
