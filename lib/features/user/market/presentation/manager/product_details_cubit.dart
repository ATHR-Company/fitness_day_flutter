import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/market/domain/entities/cart_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

sealed class ProductDetailsState {
  const ProductDetailsState();
}

class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial();
}

class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

class ProductDetailsSuccess extends ProductDetailsState {
  final ProductData product;
  final int selectedPhotoIndex;

  const ProductDetailsSuccess({
    required this.product,
    this.selectedPhotoIndex = 0,
  });

  ProductDetailsSuccess copyWith({ProductData? product, int? selectedPhotoIndex}) {
    return ProductDetailsSuccess(
      product: product ?? this.product,
      selectedPhotoIndex: selectedPhotoIndex ?? this.selectedPhotoIndex,
    );
  }
}

class ProductDetailsFailure extends ProductDetailsState {
  final String message;

  const ProductDetailsFailure(this.message);
}

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductByIdUseCase _getProductByIdUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  bool _isTogglingFavorite = false;

  ProductDetailsCubit(this._getProductByIdUseCase, this._toggleFavoriteUseCase)
      : super(const ProductDetailsInitial());

  Future<void> load(String id) async {
    emit(const ProductDetailsLoading());
    final result = await _getProductByIdUseCase(id);
    if (result is Success<ProductData>) {
      emit(ProductDetailsSuccess(product: result.data));
    } else if (result is FailureResult<ProductData>) {
      emit(ProductDetailsFailure(result.failure.message));
    }
  }

  void selectPhoto(int index) {
    final current = state;
    if (current is ProductDetailsSuccess) {
      emit(current.copyWith(selectedPhotoIndex: index));
    }
  }

  /// Flips the heart immediately, then settles on whatever the server reports —
  /// which also rolls the icon back if the request failed.
  Future<void> toggleFavorite() async {
    final current = state;
    if (current is! ProductDetailsSuccess || _isTogglingFavorite) return;

    _isTogglingFavorite = true;
    final bool previous = current.product.isFavorite;
    emit(current.copyWith(product: current.product.copyWith(isFavorite: !previous)));

    final result = await _toggleFavoriteUseCase(
      itemType: CartItemType.product,
      itemIdentity: current.product.id,
    );
    _isTogglingFavorite = false;

    final latest = state;
    if (latest is! ProductDetailsSuccess) return;

    final bool settled = result is Success<bool> ? result.data : previous;
    emit(latest.copyWith(product: latest.product.copyWith(isFavorite: settled)));
  }
}
