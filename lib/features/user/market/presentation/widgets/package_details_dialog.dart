import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/cancel_subscription_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

class PackageDetailsDialog extends StatelessWidget {
  final ProductData package;
  final bool isSubscribed;
  final String? expiryDate;

  const PackageDetailsDialog({
    super.key,
    required this.package,
    this.isSubscribed = false,
    this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    // Hardcoded features for the UI demonstration based on the provided image
    final List<String> features = [
      'market.package_feature_1'.tr(),
      'market.package_feature_2'.tr(),
      'market.package_feature_3'.tr(),
      'market.package_feature_4'.tr(),
      'market.package_feature_5'.tr(),
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'market.package_details_title'.tr(),
                    style: TextStyleManager.style15Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  PositionedDirectional(
                    start: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image
            AppImage(
              package.imageUrl,
              height: 180.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Title & Price
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      package.name,
                      style: TextStyleManager.style13Medium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                      softWrap: true,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${package.currentPrice.toInt()}',
                        style: TextStyleManager.style15Medium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'home.sar'.tr(),
                        style: TextStyleManager.style11Medium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Features List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features.map((feature) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: Icon(
                            Icons.circle,
                            color: AppColors.primary,
                            size: 10.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyleManager.style9Medium.copyWith(
                              color: AppColors.black,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16.h),

            if (isSubscribed) ...[
              // Expiry Date Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundTint,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),

                        Text(
                          'market.subscription_expiry_label'.tr(),
                          style: TextStyleManager.style9Medium.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      expiryDate ?? '',
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Cancel Subscription Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 8.h),
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      ); // Close the package details dialog
                      showDialog(
                        context: context,
                        barrierColor: AppColors.black.withValues(alpha: 0.6),
                        builder: (context) => CancelSubscriptionDialog(
                          onConfirm: () {
                            // TODO: Handle cancel logic here
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, color: AppColors.white, size: 18.sp),
                          SizedBox(width: 8.w),

                        Text(
                          'market.cancel_subscription_button'.tr(),
                          style: TextStyleManager.style13Medium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Add to Cart Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 8.h),
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppImage(
                          SvgIcons.market_icon,
                          color: AppColors.white,
                          width: 20.w,
                          height: 20.h,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'market.add_to_cart'.tr(),
                          style: TextStyleManager.style13Medium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
