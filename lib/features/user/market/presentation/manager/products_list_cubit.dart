import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/market/domain/entities/products_page_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'products_list_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class ProductsListCubit extends Cubit<ProductsListState> {
  final GetProductsUseCase _getProductsUseCase;
  final ProductsFilter filter;
  final int _limit;

  int _currentPage = 1;

  ProductsListCubit({
    required GetProductsUseCase getProductsUseCase,
    required this.filter,
    int limit = 10,
  })  : _getProductsUseCase = getProductsUseCase,
        _limit = limit,
        super(const ProductsListInitial());

  Future<void> loadFirst() async {
    _currentPage = 1;
    emit(const ProductsListLoading());
    final result = await _getProductsUseCase(
      filter: filter,
      page: 1,
      limit: _limit,
    );
    if (result is Success<ProductsPageData>) {
      emit(ProductsListSuccess(
        products: result.data.products,
        hasMore: result.data.hasMore,
      ));
    } else if (result is FailureResult<ProductsPageData>) {
      emit(ProductsListFailure(result.failure.message, error: AppError.from(result.failure)));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ProductsListSuccess || !current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    _currentPage++;

    final result = await _getProductsUseCase(
      filter: filter,
      page: _currentPage,
      limit: _limit,
    );

    if (result is Success<ProductsPageData>) {
      emit(current.copyWith(
        products: [...current.products, ...result.data.products],
        hasMore: result.data.hasMore,
        isLoadingMore: false,
      ));
    } else {
      // Roll back page counter on failure
      _currentPage--;
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
