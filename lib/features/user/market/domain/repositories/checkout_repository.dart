import 'package:fitness_day/core/network/api_result.dart';
import '../entities/order_counters_data.dart';
import '../entities/order_data.dart';

abstract class CheckoutRepository {
  Future<ApiResult<List<BranchData>>> getBranches();
  Future<ApiResult<OrderData>> checkout(CheckoutInput input);
  Future<ApiResult<OrderData>> applyCoupon({
    required String orderIdentity,
    required String? couponCode,
  });
  Future<ApiResult<OrderData>> editDelivery({
    required String orderIdentity,
    required String deliveryMethod,
  });
  Future<ApiResult<OrdersPageData>> getOrders({
    int page,
    int limit,
    String? status,
  });
  Future<ApiResult<OrderData>> getOrderById(String orderIdentity);
  Future<ApiResult<OrderCountersData>> getCounters();
}
