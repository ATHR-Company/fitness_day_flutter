import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/domain/entities/order_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/checkout_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/payment_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/checkout_exit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/paymob_webview_page.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/order_success_dialog.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/payment_pending_dialog.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_cubit.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';

/// Final review of the created order. The order already exists here, so the
/// coupon (and delivery change) are applied live against it and the summary
/// updates instantly from the order response.
class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({super.key});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _apply(BuildContext context) {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<CheckoutCubit>().applyCoupon(code);
  }

  void _confirm(BuildContext context) {
    final order = context.read<CheckoutCubit>().state.order;
    if (order == null) return;

    // The order exists but is still PENDING_PAYMENT. Card orders now go
    // through Paymob; cash orders are settled on delivery, so placing the
    // order is all there is to do.
    if (CheckoutPaymentMethod.fromApi(order.paymentMethod) ==
        CheckoutPaymentMethod.paymob) {
      context.read<PaymentCubit>().startPayment(order.id);
      return;
    }

    getIt<CartCubit>().loadCart();
    // A cash order joins the unpaid list, so the badge has to pick it up.
    getIt<CartCubit>().loadCounters();
    _showOrderSuccess(context, order);
  }

  /// Leaves the checkout for the store.
  ///
  /// The order already exists by the time this screen is shown, so the cart
  /// behind it is empty and every screen under this one (cart, addresses,
  /// payment method) refers to a checkout that is already done. Popping back
  /// into them would strand the buyer, so back always lands on the store.
  void _leaveToStore(BuildContext context) => leaveCheckoutToStore(context);

  void _showOrderSuccess(BuildContext context, OrderData? order) {
    OrderSuccessDialog.show(
      context,
      order: order,
      onGoHome: () {
        Navigator.of(context).pop();
        leaveCheckoutToStore(context);
      },
    );
  }

  // ── Payment flow ───────────────────────────────────────────────────────────

  /// Reacts to every step of the Paymob flow.
  ///
  /// The WebView result is never used as a verdict — whichever way it closes,
  /// the next move is to ask the backend what actually happened.
  Future<void> _onPaymentState(BuildContext context, PaymentState state) async {
    switch (state) {
      case PaymentWebviewReady(:final initiation):
        final result = await PaymobWebViewPage.open(
          context,
          webviewUrl: initiation.webviewUrl,
          amount: initiation.amount,
          currency: initiation.currency,
        );
        if (!context.mounted) return;
        // Dismissing the page still gets one check — the buyer may have paid
        // and then closed it — but no 60-second poll, because nothing was
        // submitted to wait on. A decline is already its own answer.
        final payment = context.read<PaymentCubit>();
        switch (result) {
          case PaymobWebViewResult.returned:
            payment.confirmPayment();
          case PaymobWebViewResult.declined:
            payment.confirmAfterDecline();
          case PaymobWebViewResult.dismissed:
            payment.confirmAfterDismiss();
        }

      case PaymentCompleted():
        // The backend has already flipped the order to PAID, bumped sales
        // counts and activated any plan subscription, so a plain refresh is
        // enough to bring the app in line.
        getIt<CartCubit>().loadCart();
        getIt<CartCubit>().loadCounters();
        getIt<UserProfileCubit>().getUserProfile();
        if (!context.mounted) return;
        _showOrderSuccess(context, context.read<CheckoutCubit>().state.order);

      case PaymentFailed(:final message):
        // `failureReason` arrives already translated to the `lang` we sent;
        // the sentinel keys are only used when the backend sends none.
        showAppSnackBar(
          context,
          text: message.startsWith('market.') ? message.tr() : message,
          isError: true,
        );
        context.read<PaymentCubit>().reset();

      case PaymentNotCompleted():
        // The order was placed and is still unpaid — payable from right here,
        // or later from the Orders screen.
        getIt<CartCubit>().loadCart();
        getIt<CartCubit>().loadCounters();
        showAppSnackBar(context, text: 'market.payment_not_completed'.tr());
        context.read<PaymentCubit>().reset();

      case PaymentAwaitingConfirmation():
        await PaymentPendingDialog.show(
          context,
          onDismiss: () {
            Navigator.of(context).pop();
            leaveCheckoutToStore(context);
          },
        );

      case PaymentError(:final message):
        showAppSnackBar(context, text: message, isError: true);
        context.read<PaymentCubit>().reset();

      case PaymentInitial():
      case PaymentInitiating():
      case PaymentConfirming():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaymentCubit>(),
      child: BlocConsumer<PaymentCubit, PaymentState>(
        listener: _onPaymentState,
        builder: (context, paymentState) {
          final bool paying = paymentState is PaymentInitiating ||
              paymentState is PaymentConfirming;

          return PopScope(
            // Intercepted so the system back gesture leaves the same way the
            // arrow does — to the store, never into the spent checkout stack.
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop && !paying) _leaveToStore(context);
            },
            child: Scaffold(
              backgroundColor: AppColors.dialogBackground,
              body: SafeArea(
                child: BlocBuilder<CheckoutCubit, CheckoutState>(
                  builder: (context, state) {
                    final order = state.order;
                    if (order == null) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    return Stack(
                      children: [
                        Column(
                          children: [
                            _buildAppBar(context),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 16.h),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildCouponSection(context, state, paying),
                                    SizedBox(height: 24.h),
                                    _buildServiceSummary(order),
                                    SizedBox(height: 24.h),
                                  ],
                                ),
                              ),
                            ),
                            _buildBottom(context, state, paying),
                          ],
                        ),
                        if (paying) const _PaymentBusyOverlay(),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: SizedBox(
        height: 47.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'market.order_summary_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _leaveToStore(context),
                child: SizedBox(
                  width: 47.w,
                  height: 47.w,
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(
      BuildContext context, CheckoutState state, bool paying) {
    final applied = state.order?.coupon;
    // Locked once the payment starts: a coupon applied after `initiate` would
    // not reduce what the buyer is actually charged, so offering it would lie.
    final isApplying = paying || state.couponStatus == CouponStatus.applying;
    final isApplied = applied != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'market.discount_coupon_title'.tr(),
          style: TextStyleManager.style15Medium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 12.h),
        // Field first, button after it — the Row is direction-aware, so this
        // reads field-then-button in English and حقل-ثم-زر in Arabic.
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48.h,
                alignment: AlignmentDirectional.centerStart,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                  ),
                ),
                child: isApplied
                    ? Text(
                        applied.code,
                        style: TextStyleManager.style13Medium.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : TextField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          hintText: 'market.coupon_hint'.tr(),
                          hintStyle: TextStyleManager.style11Medium.copyWith(
                            color: AppColors.textPlaceholder,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              height: 48.h,
              width: 100.w,
              child: ElevatedButton(
                onPressed: isApplying
                    ? null
                    : () => isApplied
                        ? context.read<CheckoutCubit>().removeCoupon()
                        : _apply(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isApplied ? AppColors.white : AppColors.primary,
                  side: isApplied
                      ? const BorderSide(color: AppColors.error)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: isApplying
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        (isApplied
                                ? 'market.remove_button'
                                : 'market.apply_button')
                            .tr(),
                        style: TextStyleManager.style13Medium.copyWith(
                          color: isApplied ? AppColors.error : AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (state.couponStatus == CouponStatus.failed &&
            state.couponError != null) ...[
          SizedBox(height: 6.h),
          Text(
            state.couponError!,
            style:
                TextStyleManager.style9Medium.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildServiceSummary(OrderData order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'market.service_summary_title'.tr(),
          style: TextStyleManager.style15Medium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _row('market.subtotal_label'.tr(), order.subtotal),
              if (order.shipping > 0) ...[
                SizedBox(height: 10.h),
                _row('market.shipping_label'.tr(), order.shipping),
              ],
              if (order.discount > 0) ...[
                SizedBox(height: 10.h),
                _row('market.discount_label'.tr(), -order.discount,
                    color: const Color(0xFFF57C00)),
              ],
              SizedBox(height: 12.h),
              Divider(color: AppColors.divider, height: 1.h),
              SizedBox(height: 12.h),
              _row('market.total_label'.tr(), order.total,
                  color: AppColors.primary, bold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, double value, {Color? color, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyleManager.style13Medium.copyWith(
            color: color ?? AppColors.black,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          '${value.toInt()} ${'home.sar'.tr()}',
          style: TextStyleManager.style13Medium.copyWith(
            color: color ?? AppColors.black,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottom(BuildContext context, CheckoutState state, bool paying) {
    final busy = paying || state.couponStatus == CouponStatus.applying;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: OutlinedButton(
                    // Leaving mid-payment would strand the confirmation poll.
                    onPressed: paying ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: Text(
                      'market.cancel_sub_confirm'.tr(),
                      style: TextStyleManager.style15Medium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: busy ? null : () => _confirm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      (CheckoutPaymentMethod.fromApi(
                                  state.order?.paymentMethod) ==
                              CheckoutPaymentMethod.paymob
                          ? 'market.pay_now'
                          : 'market.confirm_order')
                          .tr(),
                      style: TextStyleManager.style15Medium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Blocks the review screen while the checkout is being opened or the result
/// confirmed, so nothing about the order can change underneath the payment.
class _PaymentBusyOverlay extends StatelessWidget {
  const _PaymentBusyOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.black.withValues(alpha: 0.35),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16.h),
                Text(
                  'market.payment_processing'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style11Medium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
