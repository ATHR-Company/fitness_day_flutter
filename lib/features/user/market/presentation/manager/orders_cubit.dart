import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/market/domain/entities/order_data.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_orders_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class OrdersState {
  const OrdersState();
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersSuccess extends OrdersState {
  final List<OrderData> orders;

  const OrdersSuccess(this.orders);
}

class OrdersFailure extends OrdersState {
  final String message;

  const OrdersFailure(this.message);
}

class OrdersCubit extends Cubit<OrdersState> {
  final GetOrdersUseCase _getOrdersUseCase;

  OrdersCubit(this._getOrdersUseCase) : super(const OrdersInitial());

  Future<void> loadOrders() async {
    emit(const OrdersLoading());
    final result = await _getOrdersUseCase();
    if (result is Success<List<OrderData>>) {
      emit(OrdersSuccess(result.data));
    } else if (result is FailureResult<List<OrderData>>) {
      emit(OrdersFailure(result.failure.message));
    }
  }
}
