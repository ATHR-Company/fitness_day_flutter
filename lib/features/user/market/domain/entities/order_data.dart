/// How the order is fulfilled. `DELIVERY` is confirmed by the checkout response;
/// `PICKUP` is inferred (pending Postman confirmation).
enum CheckoutDeliveryMethod {
  delivery,
  pickup;

  String get apiValue =>
      this == CheckoutDeliveryMethod.pickup ? 'PICKUP' : 'DELIVERY';
}

/// Payment options. Only CASH is wired end-to-end; PAYPAL is selectable but its
/// webview handoff is not implemented yet.
enum CheckoutPaymentMethod {
  cash,
  paypal;

  String get apiValue =>
      this == CheckoutPaymentMethod.paypal ? 'PAYPAL' : 'CASH';
}

class OrderItemData {
  final String itemType;
  final String itemIdentity;
  final String name;
  final String mainPhoto;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  const OrderItemData({
    required this.itemType,
    required this.itemIdentity,
    required this.name,
    required this.mainPhoto,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });
}

class OrderCoupon {
  final String code;
  final double discountPercentage;
  final double discountAmount;

  const OrderCoupon({
    required this.code,
    this.discountPercentage = 0,
    this.discountAmount = 0,
  });
}

class OrderData {
  final String id;
  final List<OrderItemData> items;
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

  const OrderData({
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
}

/// A pickup branch from `/lookups/branches`.
class BranchData {
  final String id;
  final String name;

  const BranchData({required this.id, required this.name});
}

/// Payload for `POST /cart/checkout`.
class CheckoutInput {
  final CheckoutDeliveryMethod deliveryMethod;
  final String? addressIdentity; // required when deliveryMethod == delivery
  final String? branchIdentity; // required when deliveryMethod == pickup
  final CheckoutPaymentMethod paymentMethod;
  final String? couponCode;

  const CheckoutInput({
    required this.deliveryMethod,
    this.addressIdentity,
    this.branchIdentity,
    required this.paymentMethod,
    this.couponCode,
  });
}
