import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Shown when polling ran out of time while the payment was still unresolved.
///
/// Deliberately **not** phrased as a failure: the backend will still finish
/// the payment on its own, and telling a buyer their payment failed when it
/// actually succeeded is far worse than telling them to wait.
class PaymentPendingDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const PaymentPendingDialog({super.key, required this.onDismiss});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (_) => PaymentPendingDialog(onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                color: AppColors.primary,
                size: 36.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'market.payment_confirming_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.heading2.copyWith(color: AppColors.black),
            ),
            SizedBox(height: 12.h),
            Text(
              'market.payment_confirming_message'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.style11Medium
                  .copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'market.payment_confirming_action'.tr(),
                  style: TextStyleManager.style14Bold
                      .copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
