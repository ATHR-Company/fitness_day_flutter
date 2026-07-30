import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/market/domain/entities/order_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/orders_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/payment_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/paymob_webview_page.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/order_card.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/order_details_dialog.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/payment_pending_dialog.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_cubit.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersCubit _ordersCubit = getIt<OrdersCubit>();
  final PaymentCubit _paymentCubit = getIt<PaymentCubit>();

  @override
  void initState() {
    super.initState();
    _ordersCubit.loadOrders();
  }

  @override
  void dispose() {
    _paymentCubit.close();
    super.dispose();
  }

  /// Section 8.3: when the backend already reported a live checkout, open it
  /// directly. Only mint a new one when there isn't one — every `initiate`
  /// registers a real intention with Paymob.
  ///
  /// A failed order is the exception: its checkout is spent, so retrying always
  /// starts a fresh one (see [OrderData.resumableCheckout]).
  void _payOrder(OrderData order) {
    final resumable = order.resumableCheckout;
    if (resumable != null) {
      _paymentCubit.startPaymentWithExistingCheckout(order.id, resumable);
    } else {
      _paymentCubit.startPayment(order.id);
    }
  }

  /// Identical WebView + polling handling to the checkout flow: the page is
  /// never the verdict, the status endpoint is.
  Future<void> _onPaymentState(BuildContext context, PaymentState state) async {
    switch (state) {
      case PaymentWebviewReady(:final initiation):
        final result = await PaymobWebViewPage.open(
          context,
          webviewUrl: initiation.webviewUrl,
          amount: initiation.amount,
          currency: initiation.currency,
        );
        if (!mounted) return;
        // Only a Paymob redirect means a verdict is actually on its way; the
        // other two are settled with a single check so the buyer is handed
        // straight back to the app.
        switch (result) {
          case PaymobWebViewResult.returned:
            _paymentCubit.confirmPayment();
          case PaymobWebViewResult.declined:
            _paymentCubit.confirmAfterDecline();
          case PaymobWebViewResult.dismissed:
            _paymentCubit.confirmAfterDismiss();
        }

      case PaymentCompleted():
        getIt<CartCubit>().loadCart();
        // One fewer unpaid order — the badge has to follow.
        getIt<CartCubit>().loadCounters();
        getIt<UserProfileCubit>().getUserProfile();
        _ordersCubit.loadOrders();
        if (!mounted) return;
        showAppSnackBar(
          context,
          text: 'market.payment_completed_late'.tr(),
          isSuccess: true,
        );

      case PaymentFailed(:final message):
        _ordersCubit.loadOrders();
        showAppSnackBar(
          context,
          text: message.startsWith('market.') ? message.tr() : message,
          isError: true,
        );
        _paymentCubit.reset();

      case PaymentNotCompleted():
        // Still pending — say so plainly and leave the order payable.
        _ordersCubit.loadOrders();
        showAppSnackBar(context, text: 'market.payment_not_completed'.tr());
        _paymentCubit.reset();

      case PaymentAwaitingConfirmation():
        await PaymentPendingDialog.show(
          context,
          onDismiss: () => Navigator.of(context).pop(),
        );
        _paymentCubit.reset();

      case PaymentError(:final message):
        showAppSnackBar(context, text: message, isError: true);
        _paymentCubit.reset();

      case PaymentInitial():
      case PaymentInitiating():
      case PaymentConfirming():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _paymentCubit,
      child: BlocConsumer<PaymentCubit, PaymentState>(
        listener: _onPaymentState,
        builder: (context, paymentState) => _buildScaffold(
          context,
          isPaying: paymentState is PaymentInitiating ||
              paymentState is PaymentConfirming,
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, {required bool isPaying}) {
    return Scaffold(
      backgroundColor: AppColors.marketScaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<OrdersCubit, OrdersState>(
                bloc: _ordersCubit,
                builder: (context, state) {
                  switch (state) {
                    case OrdersInitial():
                    case OrdersLoading():
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    case OrdersFailure():
                      return _buildErrorState(state.message);
                    case OrdersSuccess():
                      final orders = state.orders;
                      if (orders.isEmpty) {
                        return _buildEmptyState();
                      }
                      return RefreshIndicator(
                        onRefresh: () => _ordersCubit.loadOrders(),
                        color: AppColors.primary,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return OrderCard(
                              order: order,
                              isBusy: isPaying,
                              // Paid orders have nothing left to do.
                              onPayTap: order.isPayable
                                  ? () => _payOrder(order)
                                  : null,
                              onTap: () => OrderDetailsDialog.show(
                                context,
                                order: order,
                                onPayTap: order.isPayable
                                    ? () => _payOrder(order)
                                    : null,
                              ),
                            );
                          },
                        ),
                      );
                  }
                },
              ),
            ),
          ],
            ),
            if (isPaying)
              Positioned.fill(
                child: ColoredBox(
                  color: AppColors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
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
              'market.orders_title'.tr(),
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
                onTap: () => Navigator.pop(context),
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

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(
            SvgIcons.market_icon,
            width: 140.w,
            color: AppColors.textPlaceholder,
          ),
          SizedBox(height: 32.h),
          Text(
            'market.no_orders_title'.tr(),
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'market.no_orders_message'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 40.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'market.go_to_products'.tr(),
                style: TextStyleManager.style13Medium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => _ordersCubit.loadOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                'market.retry_button'.tr(),
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
