import '../../domain/entities/cart_data.dart';

class CartItemModel {
  final String id;
  final String itemType;
  final String name;
  final String mainPhoto;
  final double price;
  final double? compareAtPrice;
  final String? badge;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final bool isAvailable;

  const CartItemModel({
    required this.id,
    required this.itemType,
    required this.name,
    required this.mainPhoto,
    required this.price,
    this.compareAtPrice,
    this.badge,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.isAvailable,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      itemType: json['itemType']?.toString() ?? 'PRODUCT',
      name: json['name']?.toString() ?? '',
      mainPhoto: json['mainPhoto']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
      badge: json['badge']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  CartItemData toEntity() {
    return CartItemData(
      id: id,
      itemType: CartItemType.fromApi(itemType),
      name: name,
      mainPhoto: mainPhoto,
      price: price,
      compareAtPrice: compareAtPrice,
      badge: badge,
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
      isAvailable: isAvailable,
    );
  }
}

class CartModel {
  final List<CartItemModel> items;
  final int totalItems;
  final double subtotal;
  final bool canCheckout;

  const CartModel({
    this.items = const [],
    this.totalItems = 0,
    this.subtotal = 0,
    this.canCheckout = false,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final List rawItems = json['items'] as List? ?? [];
    final Map<String, dynamic> summary =
        json['summary'] as Map<String, dynamic>? ?? const {};
    return CartModel(
      items: rawItems
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (summary['totalItems'] as num?)?.toInt() ?? 0,
      subtotal: (summary['subtotal'] as num?)?.toDouble() ?? 0.0,
      canCheckout: summary['canCheckout'] as bool? ?? false,
    );
  }

  CartData toEntity() {
    return CartData(
      items: items.map((m) => m.toEntity()).toList(),
      totalItems: totalItems,
      subtotal: subtotal,
      canCheckout: canCheckout,
    );
  }
}
