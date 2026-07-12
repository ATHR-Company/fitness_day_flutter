import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class SubscriptionBanner extends StatelessWidget {
  /// When true → shows active subscription with package name + expiry date.
  /// When false → shows "not subscribed" state with "subscribe now" button.
  final bool isSubscribed;
  final String? subscriptionName;
  final String? subscriptionEndDate;
  final VoidCallback? onSubscribeTap;
  final VoidCallback? onSubscribedTap;

  const SubscriptionBanner({
    super.key,
    this.isSubscribed = true,
    this.subscriptionName,
    this.subscriptionEndDate,
    this.onSubscribeTap,
    this.onSubscribedTap,
  });

  @override
  Widget build(BuildContext context) {
    return isSubscribed ? _buildSubscribed() : _buildUnsubscribed(context);
  }

  // ── Subscribed state ────────────────────────────────────────────────────────
  Widget _buildSubscribed() {
    // Format the ISO date to a readable string
    String formattedDate = subscriptionEndDate ?? '';
    if (subscriptionEndDate != null) {
      try {
        final dt = DateTime.parse(subscriptionEndDate!).toLocal();
        formattedDate = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {
        formattedDate = subscriptionEndDate!;
      }
    }
    return GestureDetector(
      onTap: onSubscribedTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          gradient: AppColors.timeRemainingGradient,
          borderRadius: BorderRadius.circular(35.r),
        ),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            padding: EdgeInsets.all(6.r),
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            width: 30.w,
            height: 30.w,
            child: SvgPicture.asset(SvgIcons.diamond),
          ),
          Expanded(
            child: Text(
             'home.subscription_active'.tr(
                  args: [subscriptionName ?? '']   ,
              ),
              style: TextStyleManager.style10Medium.copyWith(
                color: AppColors.greenJungle,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(35.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'home.expiry_date_label'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // ── Unsubscribed state ──────────────────────────────────────────────────────
  Widget _buildUnsubscribed(BuildContext context) {
    return Center(
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          gradient: AppColors.timeRemainingGradient,
          borderRadius: BorderRadius.circular(35.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Diamond icon
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              width: 30.w,
              height: 30.w,
              child: SvgPicture.asset(SvgIcons.diamond),
            ),

            // "Not subscribed" label
            Text(
              'home.not_subscribed'.tr(),
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.greenJungle,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(width: 8.w),

            // "Subscribe now" button
            GestureDetector(
              onTap: onSubscribeTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(35.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  'home.subscribe_now'.tr(),
                  style: TextStyleManager.style11Medium.copyWith(
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
}
