import 'package:fitness_day/core/network/api_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_data.dart';
import '../../domain/entities/favorites_page_data.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

sealed class FavoritesState {
  const FavoritesState();
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesSuccess extends FavoritesState {
  final FavoritesPageData data;

  const FavoritesSuccess(this.data);
}

class FavoritesFailure extends FavoritesState {
  final String message;

  const FavoritesFailure(this.message);
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavoritesUseCase _getFavorites;
  final ToggleFavoriteUseCase _toggleFavorite;

  FavoritesCubit(this._getFavorites, this._toggleFavorite)
      : super(const FavoritesInitial());

  Future<void> load() async {
    emit(const FavoritesLoading());
    final result = await _getFavorites();

    if (result case Success<FavoritesPageData>(:final data)) {
      emit(FavoritesSuccess(data));
      return;
    }
    if (result case FailureResult<FavoritesPageData>(:final failure)) {
      emit(FavoritesFailure(failure.message));
    }
  }

  /// Un-favouriting from this screen means the item no longer belongs here, so
  /// it is dropped from the list immediately and restored if the call fails.
  Future<void> removeFavorite({
    required CartItemType itemType,
    required String itemIdentity,
  }) async {
    final current = state;
    if (current is! FavoritesSuccess) return;

    final previous = current.data;
    emit(FavoritesSuccess(FavoritesPageData(
      products: itemType == CartItemType.product
          ? previous.products.where((p) => p.id != itemIdentity).toList()
          : previous.products,
      plans: itemType == CartItemType.plan
          ? previous.plans.where((p) => p.id != itemIdentity).toList()
          : previous.plans,
      total: previous.total > 0 ? previous.total - 1 : 0,
      page: previous.page,
      limit: previous.limit,
    )));

    final result = await _toggleFavorite(
      itemType: itemType,
      itemIdentity: itemIdentity,
    );

    if (result is! Success<bool> && !isClosed) {
      emit(FavoritesSuccess(previous));
    }
  }
}
