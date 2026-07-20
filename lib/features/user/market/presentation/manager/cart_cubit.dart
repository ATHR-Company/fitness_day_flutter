import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import '../../domain/entities/cart_data.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_cart_item_usecase.dart';
import '../../domain/usecases/update_cart_quantity_usecase.dart';

part 'cart_state.dart';

/// Shared, app-wide cart state (registered as a singleton). Every add-to-cart
/// button across the store reads membership from here so the ✓ reflects the
/// real server cart, and adding on one screen updates all others.
class CartCubit extends Cubit<CartState> {
  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final UpdateCartQuantityUseCase _updateQuantityUseCase;
  final RemoveCartItemUseCase _removeItemUseCase;

  CartCubit({
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required UpdateCartQuantityUseCase updateQuantityUseCase,
    required RemoveCartItemUseCase removeItemUseCase,
  })  : _getCartUseCase = getCartUseCase,
        _addToCartUseCase = addToCartUseCase,
        _updateQuantityUseCase = updateQuantityUseCase,
        _removeItemUseCase = removeItemUseCase,
        super(const CartState());

  Future<void> loadCart() async {
    emit(state.copyWith(isLoading: true));
    final result = await _getCartUseCase();
    if (result is Success<CartData>) {
      emit(state.copyWith(cart: result.data, isLoading: false));
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Adds one item. Returns true on success. The response carries the full
  /// post-add cart, so state is reconciled with the server rather than guessed.
  Future<bool> addToCart({
    required CartItemType itemType,
    required String itemIdentity,
    int quantity = 1,
  }) async {
    if (state.isAdding(itemIdentity)) return false;

    emit(state.copyWith(
      addingIds: {...state.addingIds, itemIdentity},
      clearError: true,
    ));

    final result = await _addToCartUseCase(CartItemInput(
      itemType: itemType,
      itemIdentity: itemIdentity,
      quantity: quantity,
    ));

    final nextAdding = {...state.addingIds}..remove(itemIdentity);

    if (result is Success<CartData>) {
      emit(state.copyWith(cart: result.data, addingIds: nextAdding));
      return true;
    }

    final message =
        result is FailureResult<CartData> ? result.failure.message : null;
    emit(state.copyWith(addingIds: nextAdding, errorMessage: message));
    return false;
  }

  /// Sets an item's quantity to [quantity] (absolute). The response returns the
  /// recomputed cart, so subtotal / canCheckout stay in sync with the server.
  Future<void> updateQuantity({
    required String itemIdentity,
    required int quantity,
  }) async {
    if (quantity < 1 || state.isAdding(itemIdentity)) return;

    emit(state.copyWith(
      addingIds: {...state.addingIds, itemIdentity},
      clearError: true,
    ));

    final result = await _updateQuantityUseCase(itemIdentity, quantity);

    final nextAdding = {...state.addingIds}..remove(itemIdentity);
    if (result is Success<CartData>) {
      emit(state.copyWith(cart: result.data, addingIds: nextAdding));
    } else {
      final message =
          result is FailureResult<CartData> ? result.failure.message : null;
      emit(state.copyWith(addingIds: nextAdding, errorMessage: message));
    }
  }

  Future<void> removeItem({required String itemIdentity}) async {
    if (state.isAdding(itemIdentity)) return;

    emit(state.copyWith(
      addingIds: {...state.addingIds, itemIdentity},
      clearError: true,
    ));

    final result = await _removeItemUseCase(itemIdentity);

    final nextAdding = {...state.addingIds}..remove(itemIdentity);
    if (result is Success<CartData>) {
      emit(state.copyWith(cart: result.data, addingIds: nextAdding));
    } else {
      final message =
          result is FailureResult<CartData> ? result.failure.message : null;
      emit(state.copyWith(addingIds: nextAdding, errorMessage: message));
    }
  }

  void clearError() => emit(state.copyWith(clearError: true));
}
