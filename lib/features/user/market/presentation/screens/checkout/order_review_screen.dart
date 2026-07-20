import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/domain/entities/order_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/checkout_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/order_success_dialog.dart';

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
    // Cash orders are already placed (PENDING_PAYMENT) — just confirm.
    getIt<CartCubit>().loadCart();
    OrderSuccessDialog.show(
      context,
      order: context.read<CheckoutCubit>().state.order,
      onGoHome: () {
        Navigator.of(context).pop();
        context.go(UserAppRoutes.store);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dialogBackground,
      body: SafeArea(
        child: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, state) {
            final order = state.order;
            if (order == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDeliverySection(context, state),
                        SizedBox(height: 24.h),
                        _buildCouponSection(context, state),
                        SizedBox(height: 24.h),
                        _buildServiceSummary(order),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
                _buildBottom(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios_rounded,
                  size: 20.sp, color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection(BuildContext context, CheckoutState state) {
    final busy = state.couponStatus == CouponStatus.applying;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'market.delivery_details_title'.tr(),
          style: TextStyleManager.style15Medium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 12.h),
        _deliveryOption(context, CheckoutDeliveryMethod.delivery,
            'market.delivery_option_shipping'.tr(), Icons.local_shipping, state, busy),
        SizedBox(height: 12.h),
        _deliveryOption(context, CheckoutDeliveryMethod.pickup,
            'market.delivery_option_branch_pickup'.tr(), Icons.inventory_2, state, busy),
      ],
    );
  }

  Widget _deliveryOption(
    BuildContext context,
    CheckoutDeliveryMethod method,
    String title,
    IconData icon,
    CheckoutState state,
    bool busy,
  ) {
    final isSelected = state.deliveryMethod == method;
    return GestureDetector(
      onTap: busy ? null : () => context.read<CheckoutCubit>().editDelivery(method),
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.greenLightAccent
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 18.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyleManager.style11Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.textPlaceholder,
                  width: isSelected ? 4 : 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context, CheckoutState state) {
    final applied = state.order?.coupon;
    final isApplying = state.couponStatus == CouponStatus.applying;
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
        Row(
          children: [
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
            SizedBox(width: 12.w),
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

  Widget _buildBottom(BuildContext context, CheckoutState state) {
    final busy = state.couponStatus == CouponStatus.applying;
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
                    onPressed: () => Navigator.pop(context),
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
                      'market.confirm_order'.tr(),
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
