import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';

class HydrationCard extends StatelessWidget {
  final double current;
  final double target;

  const HydrationCard({super.key, this.current = 2.50, this.target = 2.50});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(4.r),
          topEnd: Radius.circular(4.r),
          bottomStart: Radius.circular(4.r),
          bottomEnd: Radius.circular(32.r),
        ),
        border: Border.all(color: AppColors.greenMint, width: 0.5),
        boxShadow: AppShadows.profileItemShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                Text(
                  'home.hydration_title'.tr(),
                  style: TextStyleManager.heading3.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time_filled,
                    size: 22.sp, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  'home.hydration_all_day'.tr(),
                  style: TextStyleManager.style10Medium
                      .copyWith(color: AppColors.primary),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.check, color: AppColors.white, size: 16.sp),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // ── Body ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 72.w,
                  height: 72.w,
                  child: SvgPicture.asset(SvgIcons.waterBorder,
                      fit: BoxFit.contain),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'home.hydration_desc'.tr(),
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: current.toStringAsFixed(2),
                            style: TextStyleManager.style14Bold
                                .copyWith(color: AppColors.primary),
                          ),
                          TextSpan(
                            text: '  /  ',
                            style: TextStyleManager.style14Bold
                                .copyWith(color: AppColors.textPrimary),
                          ),
                          TextSpan(
                            text: target.toStringAsFixed(2),
                            style: TextStyleManager.style14Bold
                                .copyWith(color: AppColors.textPrimary),
                          ),
                          TextSpan(
                            text: '  ${'home.water_unit'.tr()}',
                            style: TextStyleManager.style13Medium
                                .copyWith(color: AppColors.textPrimary),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // ── Footer ──
            SizedBox(
              height: 38.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r)),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'home.details_button'.tr(),
                      style: TextStyleManager.style12Regular.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.keyboard_double_arrow_left,
                        size: 16.sp, color: AppColors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
