import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import '../../domain/entities/order_data.dart';
import '../models/order_model.dart';

abstract class CheckoutRemoteDataSource {
  Future<List<BranchModel>> getBranches();
  Future<OrderModel> checkout(CheckoutInput input);
  Future<OrderModel> applyCoupon({
    required String orderIdentity,
    required String? couponCode,
  });
  Future<OrderModel> editDelivery({
    required String orderIdentity,
    required String deliveryMethod,
  });
  Future<List<OrderModel>> getOrders();
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final ApiService apiService;

  CheckoutRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await apiService.get('/orders');
    final List raw = response.data['data']['data'] as List? ?? [];
    return raw
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BranchModel>> getBranches() async {
    final response = await apiService.get(ApiEndpoints.branches);
    final List raw = response.data['data'] as List? ?? [];
    return raw
        .map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderModel> checkout(CheckoutInput input) async {
    // Confirmed request body for DELIVERY:
    //   { deliveryMethod: "DELIVERY", addressIdentity, paymentMethod }
    // `branchIdentity` (pickup) is inferred. Coupon is intentionally NOT sent
    // here — it is applied via a separate endpoint, not the checkout body.
    final body = <String, dynamic>{
      'deliveryMethod': input.deliveryMethod.apiValue,
      'paymentMethod': input.paymentMethod.apiValue,
    };
    if (input.addressIdentity != null) {
      body['addressIdentity'] = input.addressIdentity;
    }
    if (input.branchIdentity != null) {
      body['branchIdentity'] = input.branchIdentity;
    }

    final response = await apiService.post(ApiEndpoints.cartCheckout, data: body);
    return OrderModel.fromJson(
      response.data['data'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<OrderModel> applyCoupon({
    required String orderIdentity,
    required String? couponCode,
  }) async {
    // Backend expects `code`; a null code removes the applied coupon.
    final response = await apiService.patch(
      ApiEndpoints.applyOrderCoupon(orderIdentity),
      data: {'code': couponCode},
    );
    return OrderModel.fromJson(
      response.data['data'] as Map<String, dynamic>? ?? {},
    );
  }

  // PATCH /orders/:orderIdentity/delivery — body { deliveryMethod }.
  @override
  Future<OrderModel> editDelivery({
    required String orderIdentity,
    required String deliveryMethod,
  }) async {
    final response = await apiService.patch(
      ApiEndpoints.editOrderDelivery(orderIdentity),
      data: {'deliveryMethod': deliveryMethod},
    );
    return OrderModel.fromJson(
      response.data['data'] as Map<String, dynamic>? ?? {},
    );
  }
}
