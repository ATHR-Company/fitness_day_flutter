import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/subscription_package_data.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

export 'package:fitness_day/features/user/user_home/domain/entities/subscription_package_data.dart';

class SubscriptionPackageCard extends StatelessWidget {
  final SubscriptionPackageData package;
  final String detailsLabelKey;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onDetailsTap;

  const SubscriptionPackageCard({
    super.key,
    required this.package,
    this.detailsLabelKey = 'home.details_button',
    this.isSelected = false,
    this.onTap,
    this.onFavoriteTap,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 1 : 0.5,
            ),
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
                        errorBuilder: (_, __, ___) => Container(
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.primaryShadow,
                        ),
                        child: Icon(
                          package.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: package.isFavorite ? AppColors.error : AppColors.primary,
                          size: 20.sp,
                        ),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      package.name,
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                        SizedBox(width: 2.w),
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
                      alignment: AlignmentDirectional.centerEnd,
                      child: SizedBox(
                        height: 32.h,
                        child: ElevatedButton(
                          onPressed: onDetailsTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 4.w),
                              Text(
                                detailsLabelKey.tr(),
                                style: TextStyleManager.style9Medium.copyWith(
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
        ),
      ),
    );
  }
}