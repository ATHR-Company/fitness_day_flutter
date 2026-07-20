import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/checkout_cubit.dart';

/// The order summary shown across every checkout stage.
///
/// Once an order exists (e.g. after a coupon is applied), it drives the numbers
/// from the order — `subtotal`, `discount`, `total` — so the discount is
/// reflected live. Before an order exists it falls back to the cart summary.
class OrderSummaryPanel extends StatelessWidget {
  const OrderSummaryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, checkoutState) {
        final order = checkoutState.order;

        if (order != null) {
          return _Panel(
            totalItems: order.items.fold<int>(0, (s, i) => s + i.quantity),
            subtotal: order.subtotal,
            discount: order.discount,
            total: order.total,
          );
        }

        // No order yet — mirror the cart summary.
        return BlocBuilder<CartCubit, CartState>(
          bloc: getIt<CartCubit>(),
          builder: (context, cartState) {
            final cart = cartState.cart;
            return _Panel(
              totalItems: cart.totalItems,
              subtotal: cart.subtotal,
              discount: 0,
              total: cart.subtotal,
            );
          },
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  final int totalItems;
  final double subtotal;
  final double discount;
  final double total;

  const _Panel({
    required this.totalItems,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = discount > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'market.order_summary_title'.tr(),
            style: TextStyleManager.style13Medium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _row(
          label: 'market.total_products_label'.tr(),
          value: '$totalItems',
        ),
        if (hasDiscount) ...[
          SizedBox(height: 8.h),
          _row(
            label: 'market.discount_label'.tr(),
            value: '- ${discount.toInt()}',
            valueColor: AppColors.error,
            withSar: true,
          ),
        ],
        SizedBox(height: 8.h),
        _row(
          label: 'market.total_label'.tr(),
          value: '${total.toInt()}',
          valueColor: AppColors.primary,
          withSar: true,
          bold: true,
        ),
      ],
    );
  }

  Widget _row({
    required String label,
    required String value,
    Color? valueColor,
    bool withSar = false,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyleManager.style11Medium
              .copyWith(color: AppColors.textSecondary),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyleManager.style13Medium.copyWith(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? AppColors.black,
              ),
            ),
            if (withSar) ...[
              SizedBox(width: 2.w),
              Text(
                'home.sar'.tr(),
                style: TextStyleManager.style9Medium
                    .copyWith(color: valueColor ?? AppColors.black),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
