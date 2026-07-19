import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/market/domain/entities/store_home_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_store_home_usecase.dart';
import 'market_home_state.dart';

class MarketHomeCubit extends Cubit<MarketHomeState> {
  final GetStoreHomeUseCase _getStoreHomeUseCase;

  MarketHomeCubit(this._getStoreHomeUseCase) : super(const MarketHomeInitial());

  Future<void> loadStoreHome() async {
    emit(const MarketHomeLoading());
    final result = await _getStoreHomeUseCase();
    if (result is Success<StoreHomeData>) {
      emit(MarketHomeSuccess(data: result.data));
    } else if (result is FailureResult<StoreHomeData>) {
      emit(MarketHomeFailure(result.failure.message));
    }
  }

  void selectCategory(int index) {
    final current = state;
    if (current is MarketHomeSuccess) {
      emit(current.copyWith(selectedCategoryIndex: index));
    }
  }
}
