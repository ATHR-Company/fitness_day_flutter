part of 'checkout_cubit.dart';

enum CheckoutSubmitStatus { editing, submitting, success, failure }

enum CouponStatus { idle, applying, applied, failed }

class CheckoutState extends Equatable {
  final CheckoutDeliveryMethod deliveryMethod;
  final String? addressIdentity;
  final String? branchIdentity;
  final CheckoutPaymentMethod paymentMethod;
  final String? couponCode;

  final List<BranchData> branches;
  final bool branchesLoading;

  final CheckoutSubmitStatus status;
  final OrderData? order;
  final String? errorMessage;

  // Coupon-specific state
  final CouponStatus couponStatus;
  final String? couponError;

  const CheckoutState({
    this.deliveryMethod = CheckoutDeliveryMethod.delivery,
    this.addressIdentity,
    this.branchIdentity,
    this.paymentMethod = CheckoutPaymentMethod.cash,
    this.couponCode,
    this.branches = const [],
    this.branchesLoading = false,
    this.status = CheckoutSubmitStatus.editing,
    this.order,
    this.errorMessage,
    this.couponStatus = CouponStatus.idle,
    this.couponError,
  });

  bool get canSubmit {
    if (status == CheckoutSubmitStatus.submitting) return false;
    if (deliveryMethod == CheckoutDeliveryMethod.delivery) {
      return addressIdentity != null;
    }
    return branchIdentity != null;
  }

  CheckoutState copyWith({
    CheckoutDeliveryMethod? deliveryMethod,
    String? addressIdentity,
    String? branchIdentity,
    CheckoutPaymentMethod? paymentMethod,
    String? couponCode,
    List<BranchData>? branches,
    bool? branchesLoading,
    CheckoutSubmitStatus? status,
    OrderData? order,
    String? errorMessage,
    bool clearError = false,
    CouponStatus? couponStatus,
    String? couponError,
    bool clearCouponError = false,
    bool clearCoupon = false,
  }) {
    return CheckoutState(
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      addressIdentity: addressIdentity ?? this.addressIdentity,
      branchIdentity: branchIdentity ?? this.branchIdentity,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      couponCode: clearCoupon ? null : (couponCode ?? this.couponCode),
      branches: branches ?? this.branches,
      branchesLoading: branchesLoading ?? this.branchesLoading,
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      couponStatus: couponStatus ?? this.couponStatus,
      couponError:
          clearCouponError ? null : (couponError ?? this.couponError),
    );
  }

  @override
  List<Object?> get props => [
        deliveryMethod,
        addressIdentity,
        branchIdentity,
        paymentMethod,
        couponCode,
        branches,
        branchesLoading,
        status,
        order,
        errorMessage,
        couponStatus,
        couponError,
      ];
}
