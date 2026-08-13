import 'package:equatable/equatable.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_data.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

/// Favourite flags known to this session, keyed by product/plan id.
class FavoriteStatusState extends Equatable {
  /// Every id toggled (or explicitly recorded) since launch. An id that is
  /// absent means "nothing newer than whatever the list payload reported".
  final Map<String, bool> statuses;

  /// Ids with a `POST /favorites` call in flight — drives the heart spinner.
  final Set<String> pendingIds;

  const FavoriteStatusState({
    this.statuses = const {},
    this.pendingIds = const {},
  });

  /// The flag to paint for [id], given the [serverValue] its screen was drawn
  /// with. A local toggle always wins, because it is the newer truth.
  bool isFavorite(String id, {required bool serverValue}) =>
      statuses[id] ?? serverValue;

  bool isToggling(String id) => pendingIds.contains(id);

  FavoriteStatusState copyWith({
    Map<String, bool>? statuses,
    Set<String>? pendingIds,
  }) {
    return FavoriteStatusState(
      statuses: statuses ?? this.statuses,
      pendingIds: pendingIds ?? this.pendingIds,
    );
  }

  @override
  List<Object?> get props => [statuses, pendingIds];
}

/// Single owner of the favourite flag across the store (registered as a
/// singleton, like [CartCubit]).
///
/// Cards sit inside lazily built slivers, so their `State` is discarded as soon
/// as they scroll past the cache extent and rebuilt from the payload the list
/// was drawn with — which is why a freshly favourited item scrolled back into
/// view with an empty heart. Holding the flag here, above the list, survives
/// both the recycling and a jump to another screen.
class FavoriteStatusCubit extends Cubit<FavoriteStatusState> {
  final ToggleFavoriteUseCase _toggleFavorite;

  FavoriteStatusCubit(this._toggleFavorite)
      : super(const FavoriteStatusState());

  /// Flips [id] immediately, then settles on the server's answer — which also
  /// rolls the heart back when the request failed.
  Future<void> toggle({
    required CartItemType itemType,
    required String id,
    required bool current,
  }) async {
    if (state.isToggling(id)) return;

    emit(state.copyWith(
      statuses: {...state.statuses, id: !current},
      pendingIds: {...state.pendingIds, id},
    ));

    final result = await _toggleFavorite(itemType: itemType, itemIdentity: id);
    if (isClosed) return;

    final bool settled = result is Success<bool> ? result.data : current;
    emit(state.copyWith(
      statuses: {...state.statuses, id: settled},
      pendingIds: {...state.pendingIds}..remove(id),
    ));
  }

  /// Records a flag a different screen owns the request for — the favourites
  /// list drops the row itself, and every other card has to agree with it.
  void record(String id, {required bool isFavorite}) =>
      emit(state.copyWith(statuses: {...state.statuses, id: isFavorite}));
}
