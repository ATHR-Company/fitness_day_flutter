import 'package:dio/dio.dart';
import 'package:fitness_day/core/errors/failures.dart';
import 'package:fitness_day/core/network/api_result.dart';
import '../../domain/entities/order_data.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_datasource.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<BranchData>>> getBranches() async {
    try {
      final models = await remoteDataSource.getBranches();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return FailureResult(
          ServerFailure(_messageOf(e, 'Failed to load branches')));
    }
  }

  @override
  Future<ApiResult<OrderData>> checkout(CheckoutInput input) async {
    try {
      final model = await remoteDataSource.checkout(input);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(
          ServerFailure(_messageOf(e, 'Failed to place order')));
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
      return FailureResult(
          ServerFailure(_messageOf(e, 'Failed to apply coupon')));
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
      return FailureResult(
          ServerFailure(_messageOf(e, 'Failed to update delivery')));
    }
  }

  /// Surface the backend's localized message when present.
  String _messageOf(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
    }
    return fallback;
  }
}
