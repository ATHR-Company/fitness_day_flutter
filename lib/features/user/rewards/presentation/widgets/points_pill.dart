import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

/// "نقاطك الحالية" — always fed from the balance in the latest server
/// response, never from a locally adjusted number.
class PointsPill extends StatelessWidget {
  final int points;

  const PointsPill({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundTint,
        borderRadius: BorderRadius.circular(12.r),
      ),
      // Row respects Directionality automatically:
      // RTL → label on right, value on left
      // LTR → label on left, value on right
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'awards.your_points'.tr(),
            style: TextStyleManager.style14Medium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$points',
                style: TextStyleManager.style16Bold.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 6.w),
              AppImage(SvgIcons.awardGreenFire, width: 22.r, height: 22.r),
            ],
          ),
        ],
      ),
    );
  }
}
