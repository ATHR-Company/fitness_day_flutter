import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/rewards/data/models/redemption_models.dart';

/// One coupon in "كوبوناتي". Used coupons stay in the list, greyed out — users
/// come here looking for their history, not just what is still spendable.
class RedemptionCard extends StatelessWidget {
  final RedemptionModel redemption;

  const RedemptionCard({super.key, required this.redemption});

  @override
  Widget build(BuildContext context) {
    final bool isUsed = redemption.isUsed;
    final Color accent = isUsed ? AppColors.textSecondary : AppColors.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.dividerLight, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  redemption.coupon?.name ?? '',
                  style: TextStyleManager.style14Bold.copyWith(color: accent),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isUsed
                      ? AppColors.greyBackground
                      : AppColors.backgroundTint,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isUsed
                      ? 'awards.coupon_used'.tr()
                      : 'awards.coupon_available'.tr(),
                  style: TextStyleManager.style10Medium.copyWith(color: accent),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            // A used code no longer works, so there is nothing worth copying.
            onTap: isUsed
                ? null
                : () async {
                    await Clipboard.setData(
                      ClipboardData(text: redemption.code),
                    );
                    if (!context.mounted) return;
                    showAppSnackBar(
                      context,
                      text: 'awards.code_copied'.tr(),
                      isSuccess: true,
                    );
                  },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isUsed
                    ? AppColors.greyBackground
                    : AppColors.backgroundTint,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      redemption.code,
                      style: TextStyleManager.style14Bold.copyWith(
                        color: isUsed
                            ? AppColors.textSecondary
                            : AppColors.primaryDark,
                      ),
                    ),
                  ),
                  if (!isUsed)
                    Icon(Icons.copy_rounded,
                        color: AppColors.primary, size: 18.sp),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'awards.points_spent'.tr(args: ['${redemption.pointsSpent}']),
              style: TextStyleManager.style10Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
