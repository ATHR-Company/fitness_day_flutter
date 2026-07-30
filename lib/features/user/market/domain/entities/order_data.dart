/// How the order is fulfilled. `DELIVERY` is confirmed by the checkout response;
/// `PICKUP` is inferred (pending Postman confirmation).
enum CheckoutDeliveryMethod {
  delivery,
  pickup;

  String get apiValue =>
      this == CheckoutDeliveryMethod.pickup ? 'PICKUP' : 'DELIVERY';
}

/// Payment options, both wired end-to-end.
///
/// [paymob] hands the buyer to Paymob's hosted checkout in a WebView; the
/// result is confirmed against the backend, never read off that page.
enum CheckoutPaymentMethod {
  cash,
  paymob;

  String get apiValue =>
      this == CheckoutPaymentMethod.paymob ? 'PAYMOB' : 'CASH';

  static CheckoutPaymentMethod fromApi(String? raw) =>
      raw?.toUpperCase() == 'PAYMOB'
          ? CheckoutPaymentMethod.paymob
          : CheckoutPaymentMethod.cash;
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

/// A live Paymob checkout already attached to an order, as reported by
/// `GET /orders` and `GET /orders/:id`.
///
/// When present, the buyer can be sent straight to [webviewUrl] — no
/// `initiate` call needed. `null` on an unpaid order is normal: it just means
/// no checkout is open right now (never started, or expired after an hour).
///
/// The backend deliberately does not mint one per list request — each
/// `initiate` registers a real intention with Paymob, and doing that on every
/// list load would flood their dashboard with abandoned transactions.
class OrderPaymentData {
  final String paymentIdentity;
  final String webviewUrl;
  final double amount;

  /// Rendered as returned. The host and currency differ per market, so
  /// neither is ever assumed.
  final String currency;

  final DateTime? expiresAt;

  const OrderPaymentData({
    required this.paymentIdentity,
    required this.webviewUrl,
    required this.amount,
    required this.currency,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Only usable while it points somewhere and hasn't lapsed.
  bool get isUsable => webviewUrl.isNotEmpty && !isExpired;
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
  final int? itemsCount;

  /// Currency of the amounts above, as reported by the API. Null when the
  /// response didn't carry one — callers fall back to [AppCurrency.code].
  final String? currency;

  /// The open checkout for this order, when there is one.
  final OrderPaymentData? payment;

  /// Where the order goes — the delivery address, or the branch it is picked
  /// up from. Null on responses that only report [deliveryMethod].
  final OrderDeliveryData? delivery;

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
    this.itemsCount,
    this.currency,
    this.payment,
    this.delivery,
  });

  /// True when the order is collected from a branch rather than shipped.
  ///
  /// Reads the nested `delivery` first and falls back to the flat
  /// `deliveryMethod` that the checkout response still returns.
  bool get isPickup =>
      delivery?.isPickup ?? deliveryMethod.toUpperCase() == 'PICKUP';

  /// True while the order still owes money — the only case that shows a
  /// "complete payment" action.
  bool get isPayable =>
      status == 'PENDING_PAYMENT' || status == 'PAYMENT_FAILED';

  /// The open checkout that can be reopened as-is, or null when retrying has
  /// to mint a fresh one.
  ///
  /// A `PAYMENT_FAILED` order never qualifies even when [payment] still looks
  /// usable: that Paymob intention has already resolved, so reopening its link
  /// just shows the buyer the same failure. Retrying a failed order means a
  /// new `initiate`.
  OrderPaymentData? get resumableCheckout =>
      status == 'PENDING_PAYMENT' && (payment?.isUsable ?? false)
          ? payment
          : null;
}

/// The shipping address an order was placed with.
///
/// A snapshot taken at checkout — editing or deleting the saved address later
/// must not change where a past order was sent, so this is never re-read from
/// `/addresses`.
class OrderAddressData {
  final String addressIdentity;
  final String title;
  final String district;
  final String street;
  final String postalCode;
  final double? lat;
  final double? lng;

  const OrderAddressData({
    this.addressIdentity = '',
    this.title = '',
    this.district = '',
    this.street = '',
    this.postalCode = '',
    this.lat,
    this.lng,
  });

  /// The address parts worth showing, in reading order and without the ones
  /// the backend left empty. Joining them is the UI's job — the separator is
  /// localized, and this layer stays free of translations.
  List<String> get parts => [street, district, postalCode]
      .where((part) => part.trim().isNotEmpty)
      .toList();
}

/// The branch a pickup order is collected from.
class OrderBranchData {
  final String branchIdentity;
  final String name;
  final String address;
  final String phone;
  final double? lat;
  final double? lng;

  const OrderBranchData({
    this.branchIdentity = '',
    this.name = '',
    this.address = '',
    this.phone = '',
    this.lat,
    this.lng,
  });
}

/// How an order is handed over, as reported by `GET /orders`.
///
/// Exactly one of [address] / [branch] is filled, matching [method].
class OrderDeliveryData {
  final String method;
  final OrderAddressData? address;
  final OrderBranchData? branch;

  const OrderDeliveryData({
    required this.method,
    this.address,
    this.branch,
  });

  bool get isPickup => method.toUpperCase() == 'PICKUP';
}

/// One page of `GET /orders`.
///
/// [total] is the server's count of *all* the buyer's orders, not the size of
/// [orders] — the list is paginated, so the badge on the orders icon has to
/// read this instead of `orders.length`.
class OrdersPageData {
  final List<OrderData> orders;
  final int total;

  const OrdersPageData({this.orders = const [], this.total = 0});
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
