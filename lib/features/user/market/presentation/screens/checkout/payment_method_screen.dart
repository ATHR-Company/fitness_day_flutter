import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/domain/entities/order_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/checkout_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/order_review_screen.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/order_summary_panel.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  static const List<_PaymentOption> _options = [
    _PaymentOption(
      CheckoutPaymentMethod.cash,
      'market.payment_cash',
      Icons.payments_outlined,
    ),
    _PaymentOption(
      CheckoutPaymentMethod.paypal,
      'market.payment_paypal',
      Icons.account_balance_wallet_outlined,
    ),
  ];

  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<CheckoutCubit>();
    // PayPal's webview handoff is not wired yet — only CASH can place an order.
    if (cubit.state.paymentMethod == CheckoutPaymentMethod.paypal) {
      showAppSnackBar(context, text: 'market.paypal_not_available'.tr(), isError: true);
      return;
    }

    final ok = await cubit.submit();
    if (!context.mounted) return;
    if (ok) {
      // Order created — the review screen applies the coupon live and shows
      // the discounted summary from the order.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: const OrderReviewScreen(),
          ),
        ),
      );
    } else {
      final msg = cubit.state.errorMessage;
      if (msg != null && msg.isNotEmpty) {
        showAppSnackBar(context, text: msg, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dialogBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'market.payment_method_prompt'.tr(),
                      textAlign: TextAlign.start,
                      style: TextStyleManager.style13Medium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    BlocBuilder<CheckoutCubit, CheckoutState>(
                      builder: (context, state) {
                        return Column(
                          children: _options.map((opt) {
                            final bool isSelected =
                                state.paymentMethod == opt.method;
                            return _buildOptionCard(context, opt, isSelected);
                          }).toList(),
                        );
                      },
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'market.payment_method_title'.tr(),
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
              child: Directionality.of(context) == ui.TextDirection.rtl
                  ? Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20.sp,
                      color: AppColors.black,
                    )
                  : Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20.sp,
                      color: AppColors.black,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    _PaymentOption opt,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => context.read<CheckoutCubit>().setPaymentMethod(opt.method),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(opt.icon, color: AppColors.primary, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                opt.labelKey.tr(),
                style: TextStyleManager.style13Medium.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPlaceholder,
                  width: isSelected ? 4 : 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
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
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              const OrderSummaryPanel(),
              SizedBox(height: 16.h),
              BlocBuilder<CheckoutCubit, CheckoutState>(
                builder: (context, state) {
                  final bool submitting =
                      state.status == CheckoutSubmitStatus.submitting;
                  return SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: submitting ? null : () => _confirm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        elevation: 0,
                      ),
                      child: submitting
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              'market.confirm_order'.tr(),
                              style: TextStyleManager.style15Medium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption {
  final CheckoutPaymentMethod method;
  final String labelKey;
  final IconData icon;
  const _PaymentOption(this.method, this.labelKey, this.icon);
}
