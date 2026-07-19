import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';

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

  ProductDetailsCubit(this._getProductByIdUseCase) : super(const ProductDetailsInitial());

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
}
