import '../../domain/entities/store_home_data.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class ProductsListState {
  const ProductsListState();
}

class ProductsListInitial extends ProductsListState {
  const ProductsListInitial();
}

class ProductsListLoading extends ProductsListState {
  const ProductsListLoading();
}

class ProductsListSuccess extends ProductsListState {
  final List<StoreProductItem> products;
  final bool hasMore;
  final bool isLoadingMore;

  const ProductsListSuccess({
    required this.products,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  ProductsListSuccess copyWith({
    List<StoreProductItem>? products,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProductsListSuccess(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ProductsListFailure extends ProductsListState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const ProductsListFailure(this.message, {this.error});
}
