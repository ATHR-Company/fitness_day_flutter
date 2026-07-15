import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';

class CurrentWeightCard extends StatelessWidget {
  final double? weight;
  final String unit;
  final String? status;

  const CurrentWeightCard({
    super.key,
    this.weight,
    this.unit = 'kg',
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundTint,
        border: Border.all(color: AppColors.greenMint, width: 0.3.r),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppShadows.profileItemShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.current_weight_title'.tr(),
            style: TextStyleManager.heading3.copyWith(color: AppColors.black),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Scale icon ──────────────────────────────────────
              AppImage(SvgIcons.visitBorder, width: 60.w, height: 60.h),
              SizedBox(width: 2.w),

              // ── Label + value ───────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home.current_weight_title'.tr(),
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          weight != null
                              ? weight!.toStringAsFixed(1)
                              : '--',
                          style: TextStyleManager.style15Medium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          unit,
                          style: TextStyleManager.style11Medium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Status badge — fixed width, always visible ──────
              Container(
                constraints: BoxConstraints(
                  // minWidth: 60.w,
                  // maxWidth: 90.w,
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greenMint, width: 1.r),
                  gradient: AppColors.weightStatusGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status ?? 'home.weight_status_healthy'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
