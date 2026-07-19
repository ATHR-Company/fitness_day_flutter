import '../../domain/entities/store_home_data.dart';

sealed class MarketHomeState {
  const MarketHomeState();
}

class MarketHomeInitial extends MarketHomeState {
  const MarketHomeInitial();
}

class MarketHomeLoading extends MarketHomeState {
  const MarketHomeLoading();
}

class MarketHomeSuccess extends MarketHomeState {
  final StoreHomeData data;
  final int selectedCategoryIndex;

  const MarketHomeSuccess({
    required this.data,
    this.selectedCategoryIndex = 0,
  });

  MarketHomeSuccess copyWith({
    StoreHomeData? data,
    int? selectedCategoryIndex,
  }) {
    return MarketHomeSuccess(
      data: data ?? this.data,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
    );
  }
}

class MarketHomeFailure extends MarketHomeState {
  final String message;

  const MarketHomeFailure(this.message);
}
