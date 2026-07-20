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

  const CartState({
    this.cart = const CartData(),
    this.addingIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  bool isInCart(String id) => cart.containsItem(id);
  bool isAdding(String id) => addingIds.contains(id);

  int get totalItems => cart.totalItems;

  CartState copyWith({
    CartData? cart,
    Set<String>? addingIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      addingIds: addingIds ?? this.addingIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [cart, addingIds, isLoading, errorMessage];
}
