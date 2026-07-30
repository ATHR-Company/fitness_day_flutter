import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Sticky bottom sheet shown when the cart has items.
/// Displays the order summary and the "next / checkout" button.
class CartBottomSummary extends StatelessWidget {
  final CartState state;

  const CartBottomSummary({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cart = state.cart;
    final bool canCheckout = cart.canCheckout;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              SizedBox(height: 16.h),

              // "Order summary" label
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

              // Total products row
              _SummaryRow(
                label: 'market.total_products_label'.tr(),
                value: '${cart.totalItems}',
                valueStyle: TextStyleManager.style13Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),

              SizedBox(height: 8.h),

              // Total price row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'market.total_label'.tr(),
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${cart.subtotal.toInt()}',
                        style: TextStyleManager.style13Medium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'home.sar'.tr(),
                        style: TextStyleManager.style9Medium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Checkout-blocked hint
              if (!canCheckout) ...[
                SizedBox(height: 8.h),
                Text(
                  'market.cannot_checkout_hint'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],

              SizedBox(height: 16.h),

              // Checkout button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: canCheckout
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'market.next_button'.tr(),
                    style: TextStyleManager.style15Medium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
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

// ─── Summary row helper ───────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(value, style: valueStyle),
      ],
    );
  }
}
