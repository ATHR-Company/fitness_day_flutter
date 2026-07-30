import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/rewards/data/models/redemption_models.dart';

/// Shown right after a successful redeem. The code is the whole point of the
/// purchase, so it is large and copyable — the user applies it at checkout.
Future<void> showCouponCodeDialog(
  BuildContext context,
  RedemptionModel redemption,
) {
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.black.withValues(alpha: 0.5),
    builder: (_) => _CouponCodeDialog(redemption: redemption),
  );
}

class _CouponCodeDialog extends StatelessWidget {
  final RedemptionModel redemption;

  const _CouponCodeDialog({required this.redemption});

  @override
  Widget build(BuildContext context) {
    final RedemptionCouponModel? coupon = redemption.coupon;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_giftcard_rounded,
                color: AppColors.primary, size: 44.sp),
            SizedBox(height: 12.h),
            Text(
              coupon?.name ?? '',
              textAlign: TextAlign.center,
              style: TextStyleManager.heading2.copyWith(color: AppColors.black),
            ),
            SizedBox(height: 6.h),
            Text(
              'awards.coupon_ready'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),

            // ── The code ──────────────────────────────────────────────
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: redemption.code));
                if (!context.mounted) return;
                showAppSnackBar(
                  context,
                  text: 'awards.code_copied'.tr(),
                  isSuccess: true,
                );
              },
              child: Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundTint,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.greenMint),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        redemption.code,
                        style: TextStyleManager.style16Bold.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    Icon(Icons.copy_rounded,
                        color: AppColors.primary, size: 20.sp),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),
            Text(
              'awards.coupon_single_use'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.style10Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'check_in.close'.tr(),
                  style:
                      TextStyleManager.button.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
