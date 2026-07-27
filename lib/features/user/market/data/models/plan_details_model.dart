import '../../domain/entities/plans_data.dart';

class PlanDetailsModel {
  final String id;
  final String name;
  final String coverPhoto;
  final List<String> photos;
  final double price;
  final double? compareAtPrice;
  final String? badge;
  final List<String> descriptions;
  final bool isFavorite;
  final CurrentSubscription? subscription;

  PlanDetailsModel({
    required this.id,
    required this.name,
    required this.coverPhoto,
    required this.photos,
    required this.price,
    this.compareAtPrice,
    this.badge,
    required this.descriptions,
    this.isFavorite = false,
    this.subscription,
  });

  factory PlanDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final rawPhotos = data['photos'] as List? ?? [];
    final rawDescriptions = data['descriptions'] as List? ?? [];

    // `subscription` is only present when the user is subscribed to this plan.
    final rawSub = data['subscription'];
    final CurrentSubscription? subscription = rawSub is Map
        ? CurrentSubscription(
            id: rawSub['id']?.toString() ?? '',
            name: rawSub['name']?.toString() ?? '',
            endDate: rawSub['endDate']?.toString() ?? '',
          )
        : null;

    return PlanDetailsModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      coverPhoto: data['coverPhoto'] ?? '',
      photos: rawPhotos.map((e) => e.toString()).toList(),
      price: (data['price'] as num?)?.toDouble() ?? 0,
      compareAtPrice: (data['compareAtPrice'] as num?)?.toDouble(),
      badge: data['badge'] as String?,
      descriptions: rawDescriptions.map((e) => e.toString()).toList(),
      isFavorite: data['isFavorite'] ?? false,
      subscription: subscription,
    );
  }

  PlanDetails toEntity() {
    return PlanDetails(
      id: id,
      name: name,
      coverPhoto: coverPhoto,
      photos: photos,
      price: price,
      compareAtPrice: compareAtPrice,
      badge: badge,
      descriptions: descriptions,
      isFavorite: isFavorite,
      subscription: subscription,
    );
  }
}
