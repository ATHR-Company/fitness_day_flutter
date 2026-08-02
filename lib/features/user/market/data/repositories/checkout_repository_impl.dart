import 'package:fitness_day/core/network/api_result.dart';
import '../../domain/entities/order_counters_data.dart';
import '../../domain/entities/order_data.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_datasource.dart';
import 'package:fitness_day/core/errors/error_handler.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<BranchData>>> getBranches() async {
    try {
      final models = await remoteDataSource.getBranches();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<OrderData>> checkout(CheckoutInput input) async {
    try {
      final model = await remoteDataSource.checkout(input);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<OrderData>> applyCoupon({
    required String orderIdentity,
    required String? couponCode,
  }) async {
    try {
      final model = await remoteDataSource.applyCoupon(
        orderIdentity: orderIdentity,
        couponCode: couponCode,
      );
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<OrderData>> editDelivery({
    required String orderIdentity,
    required String deliveryMethod,
  }) async {
    try {
      final model = await remoteDataSource.editDelivery(
        orderIdentity: orderIdentity,
        deliveryMethod: deliveryMethod,
      );
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<OrdersPageData>> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final page0 = await remoteDataSource.getOrders(
        page: page,
        limit: limit,
        status: status,
      );
      return Success(OrdersPageData(
        orders: page0.orders.map((m) => m.toEntity()).toList(),
        total: page0.total,
      ));
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<OrderData>> getOrderById(String orderIdentity) async {
    try {
      final model = await remoteDataSource.getOrderById(orderIdentity);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<OrderCountersData>> getCounters() async {
    try {
      final model = await remoteDataSource.getCounters();
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

}
