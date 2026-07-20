import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import '../../domain/entities/order_data.dart';
import '../../domain/usecases/apply_coupon_usecase.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/usecases/edit_delivery_usecase.dart';
import '../../domain/usecases/get_branches_usecase.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutUseCase _checkoutUseCase;
  final ApplyCouponUseCase _applyCouponUseCase;
  final EditDeliveryUseCase _editDeliveryUseCase;
  final GetBranchesUseCase _getBranchesUseCase;

  CheckoutCubit({
    required CheckoutUseCase checkoutUseCase,
    required ApplyCouponUseCase applyCouponUseCase,
    required EditDeliveryUseCase editDeliveryUseCase,
    required GetBranchesUseCase getBranchesUseCase,
  })  : _checkoutUseCase = checkoutUseCase,
        _applyCouponUseCase = applyCouponUseCase,
        _editDeliveryUseCase = editDeliveryUseCase,
        _getBranchesUseCase = getBranchesUseCase,
        super(const CheckoutState());

  void setDeliveryMethod(CheckoutDeliveryMethod method) {
    emit(state.copyWith(deliveryMethod: method));
    if (method == CheckoutDeliveryMethod.pickup && state.branches.isEmpty) {
      loadBranches();
    }
  }

  void setAddress(String addressIdentity) =>
      emit(state.copyWith(addressIdentity: addressIdentity));

  void setBranch(String branchIdentity) =>
      emit(state.copyWith(branchIdentity: branchIdentity));

  void setPaymentMethod(CheckoutPaymentMethod method) =>
      emit(state.copyWith(paymentMethod: method));

  void setCoupon(String? code) =>
      emit(state.copyWith(
        couponCode: (code != null && code.isEmpty) ? null : code,
        couponStatus: CouponStatus.idle,
        clearCouponError: true,
      ));

  /// Calls `PATCH /orders/:orderIdentity/coupon`.
  /// Requires an existing order in state (order must be placed first).
  Future<void> applyCoupon(String couponCode) async {
    final orderId = state.order?.id;
    if (orderId == null || couponCode.trim().isEmpty) return;

    emit(state.copyWith(
      couponStatus: CouponStatus.applying,
      clearCouponError: true,
    ));

    final result = await _applyCouponUseCase(
      orderIdentity: orderId,
      couponCode: couponCode.trim(),
    );

    if (result is Success<OrderData>) {
      emit(state.copyWith(
        order: result.data,
        couponCode: couponCode.trim(),
        couponStatus: CouponStatus.applied,
      ));
    } else if (result is FailureResult<OrderData>) {
      emit(state.copyWith(
        couponStatus: CouponStatus.failed,
        couponError: result.failure.message,
      ));
    }
  }

  /// Removes the applied coupon from the order (`code: null`).
  Future<void> removeCoupon() async {
    final orderId = state.order?.id;
    if (orderId == null) return;

    emit(state.copyWith(
      couponStatus: CouponStatus.applying,
      clearCouponError: true,
    ));

    final result =
        await _applyCouponUseCase(orderIdentity: orderId, couponCode: null);

    if (result is Success<OrderData>) {
      emit(state.copyWith(
        order: result.data,
        couponStatus: CouponStatus.idle,
        clearCoupon: true,
      ));
    } else if (result is FailureResult<OrderData>) {
      emit(state.copyWith(
        couponStatus: CouponStatus.failed,
        couponError: result.failure.message,
      ));
    }
  }

  /// Changes the delivery method on the existing order
  /// (`PATCH /orders/:id/delivery`) and refreshes the order totals.
  Future<void> editDelivery(CheckoutDeliveryMethod method) async {
    final orderId = state.order?.id;
    if (orderId == null || method == state.deliveryMethod) return;

    emit(state.copyWith(deliveryMethod: method));

    final result = await _editDeliveryUseCase(
      orderIdentity: orderId,
      deliveryMethod: method.apiValue,
    );

    if (result is Success<OrderData>) {
      emit(state.copyWith(order: result.data));
    } else if (result is FailureResult<OrderData>) {
      emit(state.copyWith(errorMessage: result.failure.message));
    }
  }

  Future<void> loadBranches() async {
    emit(state.copyWith(branchesLoading: true));
    final result = await _getBranchesUseCase();
    if (result is Success<List<BranchData>>) {
      emit(state.copyWith(branches: result.data, branchesLoading: false));
    } else {
      emit(state.copyWith(branchesLoading: false));
    }
  }

  /// Places the order. Returns true on success (order available in state).
  Future<bool> submit() async {
    if (!state.canSubmit) return false;

    emit(state.copyWith(
      status: CheckoutSubmitStatus.submitting,
      clearError: true,
    ));

    final result = await _checkoutUseCase(CheckoutInput(
      deliveryMethod: state.deliveryMethod,
      addressIdentity: state.deliveryMethod == CheckoutDeliveryMethod.delivery
          ? state.addressIdentity
          : null,
      branchIdentity: state.deliveryMethod == CheckoutDeliveryMethod.pickup
          ? state.branchIdentity
          : null,
      paymentMethod: state.paymentMethod,
      couponCode: state.couponCode,
    ));

    if (result is Success<OrderData>) {
      // The order now exists — coupon and delivery edits happen on the review
      // screen against this order, where the summary updates live.
      emit(state.copyWith(
        status: CheckoutSubmitStatus.success,
        order: result.data,
      ));
      return true;
    }

    final message =
        result is FailureResult<OrderData> ? result.failure.message : null;
    emit(state.copyWith(
      status: CheckoutSubmitStatus.failure,
      errorMessage: message,
    ));
    return false;
  }
}
