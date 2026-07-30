part of 'cart_cubit.dart';

class CartState extends Equatable {
  final CartData cart;

  /// Item identities with an in-flight add request — drives the per-button
  /// spinner so only the tapped card shows loading.
  final Set<String> addingIds;
  final bool isLoading;

  /// Last add-to-cart error (already localized by the backend). Transient —
  /// consumed by a listener to show a snackbar, then cleared.
  final String? errorMessage;

  /// Badge counts from `GET /orders/counters` — the single source for both the
  /// cart badge and the orders badge. Null until fetched.
  final OrderCountersData? counters;

  /// True once the server's cart has been fetched at least once — that is what
  /// makes an empty [cart] trustworthy rather than merely "not loaded yet".
  final bool hasLoadedCart;

  const CartState({
    this.cart = const CartData(),
    this.addingIds = const {},
    this.isLoading = false,
    this.errorMessage,
    this.counters,
    this.hasLoadedCart = false,
  });

  bool isInCart(String id) => cart.containsItem(id);
  bool isAdding(String id) => addingIds.contains(id);

  int get totalItems => cart.totalItems;

  /// What the cart badge shows.
  ///
  /// Once the cart itself has been pulled it wins outright — including when it
  /// is empty, otherwise emptying the cart would leave the badge stuck on the
  /// counters' older number. Before that, `cartItemsCount` from
  /// `GET /orders/counters` seeds it.
  int get badgeCount =>
      hasLoadedCart ? cart.totalItems : (counters?.cartItemsCount ?? 0);

  /// Drives the "you have unpaid orders" indicator.
  int get pendingPaymentOrdersCount =>
      counters?.pendingPaymentOrdersCount ?? 0;

  CartState copyWith({
    CartData? cart,
    Set<String>? addingIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    OrderCountersData? counters,
    bool? hasLoadedCart,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      addingIds: addingIds ?? this.addingIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      counters: counters ?? this.counters,
      hasLoadedCart: hasLoadedCart ?? this.hasLoadedCart,
    );
  }

  @override
  List<Object?> get props => [
        cart,
        addingIds,
        isLoading,
        errorMessage,
        counters?.cartItemsCount,
        counters?.pendingPaymentOrdersCount,
        hasLoadedCart,
      ];
}
