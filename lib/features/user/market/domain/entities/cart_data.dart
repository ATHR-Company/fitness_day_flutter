/// Discriminates the two things that can live in the cart. The backend expects
/// the uppercase `itemType` string (`PRODUCT` / `PLAN`) on every add request.
enum CartItemType {
  product,
  plan;

  String get apiValue => this == CartItemType.plan ? 'PLAN' : 'PRODUCT';

  static CartItemType fromApi(String? value) =>
      value == 'PLAN' ? CartItemType.plan : CartItemType.product;
}

class CartItemData {
  final String id;
  final CartItemType itemType;
  final String name;
  final String mainPhoto;
  final double price;
  final double? compareAtPrice;
  final String? badge;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final bool isAvailable;

  const CartItemData({
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
}

class CartData {
  final List<CartItemData> items;
  final int totalItems;
  final double subtotal;
  final bool canCheckout;

  const CartData({
    this.items = const [],
    this.totalItems = 0,
    this.subtotal = 0,
    this.canCheckout = false,
  });

  /// A product/plan is "in the cart" when its identity matches a line item.
  /// Drives the ✓ state on add-to-cart buttons across the store.
  bool containsItem(String id) => items.any((i) => i.id == id);
}

/// Payload for `POST /cart`.
class CartItemInput {
  final CartItemType itemType;
  final String itemIdentity;
  final int quantity;

  const CartItemInput({
    required this.itemType,
    required this.itemIdentity,
    this.quantity = 1,
  });
}
