import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/domain/entities/order_data.dart';

class OrderSuccessDialog extends StatefulWidget {
  final VoidCallback onGoHome;
  final OrderData? order;

  const OrderSuccessDialog({super.key, required this.onGoHome, this.order});

  @override
  State<OrderSuccessDialog> createState() => _OrderSuccessDialogState();

  /// Show the dialog — returns when the user dismisses it.
  static Future<void> show(BuildContext context,
      {required VoidCallback onGoHome, OrderData? order}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (_) => OrderSuccessDialog(onGoHome: onGoHome, order: order),
    );
  }
}

class _OrderSuccessDialogState extends State<OrderSuccessDialog> {
  final int _rating = 4; // default 4 stars

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Close button ──────────────────────────────────────────────
            Align(
              alignment: AlignmentDirectional.topStart,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, size: 22.sp, color: AppColors.primary),
              ),
            ),
            SizedBox(height: 8.h),

            // ── Success icon ──────────────────────────────────────────────
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppImage(
                  SvgIcons.branchPickup,
                  color: AppColors.primary,
                  // size: 36.sp,
                  width: 55.w,
                  height: 55.w,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              'market.order_success_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),

          
            if (order != null && order.id.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                '${'market.order_number_label'.tr()}: ${order.id}',
                textAlign: TextAlign.center,
                style: TextStyleManager.style9Medium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            // ── Price breakdown (shows the applied coupon discount) ────────
            if (order != null) ...[
              SizedBox(height: 16.h),
              _priceRow('market.subtotal_label'.tr(), order.subtotal),
              if (order.discount > 0) ...[
                SizedBox(height: 6.h),
                _priceRow('market.discount_label'.tr(), -order.discount,
                    color: AppColors.error),
              ],
              SizedBox(height: 6.h),
              Divider(color: AppColors.divider, height: 12.h),
              _priceRow('market.total_label'.tr(), order.total,
                  color: AppColors.primary, bold: true),
            ],
            SizedBox(height: 20.h),

            

            // ── Home button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: widget.onGoHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'market.go_home_button'.tr(),
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
    );
  }

  Widget _priceRow(String label, double value, {Color? color, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.textSecondary,
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
}
