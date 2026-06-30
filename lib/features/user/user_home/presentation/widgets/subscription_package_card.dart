import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';

class SubscriptionPackageData {
  final String imageUrl;
  final String name;
  final int currentPrice;
  final int oldPrice;
  final bool isFavorite;

  const SubscriptionPackageData({
    required this.imageUrl,
    required this.name,
    required this.currentPrice,
    required this.oldPrice,
    this.isFavorite = false,
  });
}

class SubscriptionPackageCard extends StatelessWidget {
  final SubscriptionPackageData package;

  const SubscriptionPackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image and Favorite Button
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  child: Image.network(
                    package.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.backgroundTint,
                      child: Center(
                        child: Icon(Icons.image_outlined, color: AppColors.greenMint),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.primaryShadow,
                    ),
                    child: Icon(
                      package.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // ✅ يمدد العناصر لعرض الكارت كامل
              children: [
                Text(
                  package.name,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start, // ✅ العنوان يبدأ من البداية (يمين في RTL / شمال في LTR)
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start, // ✅ السعر يبدأ من البداية بدل النص
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${package.currentPrice}',
                      style: TextStyleManager.style15Medium.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'home.sar'.tr(),
                      style: TextStyleManager.style9Medium.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '${package.oldPrice} ${'home.sar'.tr()}',
                      style: TextStyleManager.style9Medium.copyWith(
                        color: AppColors.error,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerLeft, // ✅ الزرار في آخر السطر
                  child: SizedBox(
                    height: 32.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 10.w), // ✅ بديل لـ EdgeInsets.zero عشان الزرار ميبقاش ملتصق
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 4.w),

                          Text(
                            'home.details_button'.tr(),
                            style: TextStyleManager.style11Medium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.keyboard_double_arrow_left, size: 14.sp, color: AppColors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}