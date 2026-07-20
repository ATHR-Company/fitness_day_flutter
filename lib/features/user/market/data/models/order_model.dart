import '../../domain/entities/order_data.dart';

class OrderItemModel {
  final String itemType;
  final String itemIdentity;
  final String name;
  final String mainPhoto;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  const OrderItemModel({
    required this.itemType,
    required this.itemIdentity,
    required this.name,
    required this.mainPhoto,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      itemType: json['itemType']?.toString() ?? '',
      itemIdentity: json['itemIdentity']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mainPhoto: json['mainPhoto']?.toString() ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  OrderItemData toEntity() => OrderItemData(
        itemType: itemType,
        itemIdentity: itemIdentity,
        name: name,
        mainPhoto: mainPhoto,
        unitPrice: unitPrice,
        quantity: quantity,
        lineTotal: lineTotal,
      );
}

class OrderModel {
  final String id;
  final List<OrderItemModel> items;
  final String deliveryMethod;
  final String? addressIdentity;
  final String? branchIdentity;
  final String paymentMethod;
  final String status;
  final double subtotal;
  final double discount;
  final double shipping;
  final double total;
  final OrderCoupon? coupon;
  final String createdAt;

  const OrderModel({
    required this.id,
    this.items = const [],
    required this.deliveryMethod,
    this.addressIdentity,
    this.branchIdentity,
    required this.paymentMethod,
    required this.status,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    this.coupon,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List rawItems = json['items'] as List? ?? [];
    return OrderModel(
      id: json['id']?.toString() ?? '',
      items: rawItems
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      deliveryMethod: json['deliveryMethod']?.toString() ?? '',
      addressIdentity: json['addressIdentity']?.toString(),
      branchIdentity: json['branchIdentity']?.toString(),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      coupon: _parseCoupon(json['coupon']),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  static OrderCoupon? _parseCoupon(dynamic raw) {
    if (raw is! Map) return null;
    final code = raw['code']?.toString();
    if (code == null || code.isEmpty) return null;
    return OrderCoupon(
      code: code,
      discountPercentage: (raw['discountPercentage'] as num?)?.toDouble() ?? 0,
      discountAmount: (raw['discountAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  OrderData toEntity() => OrderData(
        id: id,
        items: items.map((m) => m.toEntity()).toList(),
        deliveryMethod: deliveryMethod,
        addressIdentity: addressIdentity,
        branchIdentity: branchIdentity,
        paymentMethod: paymentMethod,
        status: status,
        subtotal: subtotal,
        discount: discount,
        shipping: shipping,
        total: total,
        coupon: coupon,
        createdAt: createdAt,
      );
}

class BranchModel {
  final String id;
  final String name;

  const BranchModel({required this.id, required this.name});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  BranchData toEntity() => BranchData(id: id, name: name);
}
