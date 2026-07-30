import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/rewards/data/models/redemption_models.dart';
import 'package:fitness_day/features/user/rewards/domain/usecases/get_redemptions_usecase.dart';

part 'my_coupons_state.dart';

/// "كوبوناتي" — the coupons this user already paid points for, paginated.
///
/// Used ones are kept in the list rather than filtered out; the screen greys
/// them instead, because users come here looking for their history.
class MyCouponsCubit extends Cubit<MyCouponsState> {
  final GetRedemptionsUseCase _getRedemptionsUseCase;

  MyCouponsCubit({required GetRedemptionsUseCase getRedemptionsUseCase})
      : _getRedemptionsUseCase = getRedemptionsUseCase,
        super(const MyCouponsInitial());

  static const int _limit = 10;
  int _page = 1;

  Future<void> loadFirstPage() async {
    if (isClosed) return;
    emit(const MyCouponsLoading());
    _page = 1;

    final result = await _getRedemptionsUseCase(page: _page, limit: _limit);
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(MyCouponsLoaded(
          redemptions: data.redemptions,
          hasMore: data.hasMore,
        ));
      case FailureResult(:final failure):
        emit(MyCouponsFailure(failure.message));
    }
  }

  Future<void> loadNextPage() async {
    final current = state;
    if (current is! MyCouponsLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final result = await _getRedemptionsUseCase(page: _page + 1, limit: _limit);
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        _page = data.page;
        emit(MyCouponsLoaded(
          redemptions: [...current.redemptions, ...data.redemptions],
          hasMore: data.hasMore,
        ));
      case FailureResult():
        // Keep what is already on screen; the user can pull to retry.
        emit(current.copyWith(isLoadingMore: false));
    }
  }
}
