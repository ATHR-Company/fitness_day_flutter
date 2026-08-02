part of 'my_coupons_cubit.dart';

sealed class MyCouponsState {
  const MyCouponsState();
}

class MyCouponsInitial extends MyCouponsState {
  const MyCouponsInitial();
}

class MyCouponsLoading extends MyCouponsState {
  const MyCouponsLoading();
}

class MyCouponsLoaded extends MyCouponsState {
  final List<RedemptionModel> redemptions;
  final bool hasMore;
  final bool isLoadingMore;

  const MyCouponsLoaded({
    required this.redemptions,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  MyCouponsLoaded copyWith({
    List<RedemptionModel>? redemptions,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MyCouponsLoaded(
      redemptions: redemptions ?? this.redemptions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class MyCouponsFailure extends MyCouponsState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const MyCouponsFailure(this.message, {this.error});
}
