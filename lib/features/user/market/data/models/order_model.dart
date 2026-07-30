import '../../domain/entities/order_counters_data.dart';
import '../../domain/entities/order_data.dart';

class OrderCountersModel {
  final int cartItemsCount;
  final int cartLinesCount;
  final int pendingPaymentOrdersCount;

  const OrderCountersModel({
    this.cartItemsCount = 0,
    this.cartLinesCount = 0,
    this.pendingPaymentOrdersCount = 0,
  });

  factory OrderCountersModel.fromJson(Map<String, dynamic> json) {
    return OrderCountersModel(
      cartItemsCount: (json['cartItemsCount'] as num?)?.toInt() ?? 0,
      cartLinesCount: (json['cartLinesCount'] as num?)?.toInt() ?? 0,
      pendingPaymentOrdersCount:
          (json['pendingPaymentOrdersCount'] as num?)?.toInt() ?? 0,
    );
  }

  OrderCountersData toEntity() => OrderCountersData(
        cartItemsCount: cartItemsCount,
        cartLinesCount: cartLinesCount,
        pendingPaymentOrdersCount: pendingPaymentOrdersCount,
      );
}

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
  final int? itemsCount;
  final String? currency;
  final OrderPaymentData? payment;
  final OrderDeliveryData? delivery;

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
    this.itemsCount,
    this.currency,
    this.payment,
    this.delivery,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List rawItems = json['items'] as List? ?? [];
    // `GET /orders` nests everything under `delivery`; the checkout response
    // still returns the flat fields, so both shapes are read.
    final delivery = _parseDelivery(json['delivery']);
    return OrderModel(
      id: json['id']?.toString() ?? '',
      items: rawItems
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      deliveryMethod:
          json['deliveryMethod']?.toString() ?? delivery?.method ?? '',
      addressIdentity: json['addressIdentity']?.toString() ??
          delivery?.address?.addressIdentity,
      branchIdentity: json['branchIdentity']?.toString() ??
          delivery?.branch?.branchIdentity,
      delivery: delivery,
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      coupon: _parseCoupon(json['coupon']),
      createdAt: json['createdAt']?.toString() ?? '',
      itemsCount: (json['itemsCount'] as num?)?.toInt(),
      currency: json['currency']?.toString() ??
          // Orders carry their currency inside `payment`; the order itself
          // only reports one on endpoints that include it.
          (json['payment'] is Map
              ? (json['payment'] as Map)['currency']?.toString()
              : null),
      payment: _parsePayment(json['payment']),
    );
  }

  static OrderPaymentData? _parsePayment(dynamic raw) {
    if (raw is! Map) return null;
    final String url = raw['webviewUrl']?.toString() ?? '';
    if (url.isEmpty) return null;

    return OrderPaymentData(
      paymentIdentity: raw['paymentIdentity']?.toString() ?? '',
      webviewUrl: url,
      amount: (raw['amount'] as num?)?.toDouble() ?? 0,
      currency: raw['currency']?.toString() ?? '',
      expiresAt: DateTime.tryParse(raw['expiresAt']?.toString() ?? ''),
    );
  }

  static OrderDeliveryData? _parseDelivery(dynamic raw) {
    if (raw is! Map) return null;

    final rawAddress = raw['address'];
    final rawBranch = raw['branch'];

    return OrderDeliveryData(
      method: raw['method']?.toString() ?? '',
      address: rawAddress is Map
          ? OrderAddressData(
              addressIdentity: rawAddress['addressIdentity']?.toString() ?? '',
              title: rawAddress['title']?.toString() ?? '',
              district: rawAddress['district']?.toString() ?? '',
              street: rawAddress['street']?.toString() ?? '',
              postalCode: rawAddress['postalCode']?.toString() ?? '',
              lat: _lat(rawAddress['location']),
              lng: _lng(rawAddress['location']),
            )
          : null,
      branch: rawBranch is Map
          ? OrderBranchData(
              branchIdentity: rawBranch['branchIdentity']?.toString() ?? '',
              name: rawBranch['name']?.toString() ?? '',
              address: rawBranch['address']?.toString() ?? '',
              phone: rawBranch['phone']?.toString() ?? '',
              lat: _lat(rawBranch['location']),
              lng: _lng(rawBranch['location']),
            )
          : null,
    );
  }

  static double? _lat(dynamic location) =>
      location is Map ? (location['lat'] as num?)?.toDouble() : null;

  static double? _lng(dynamic location) =>
      location is Map ? (location['lng'] as num?)?.toDouble() : null;

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
        itemsCount: itemsCount,
        currency: currency,
        payment: payment,
        delivery: delivery,
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
