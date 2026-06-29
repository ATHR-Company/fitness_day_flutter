import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';

class StatCardsRow extends StatelessWidget {
  final String nextVisitDate;
  final String visitsCount;

  const StatCardsRow({
    super.key,
    this.nextVisitDate = '4/8/2026',
    this.visitsCount = '2',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            iconPath: SvgIcons.clendBorder,
            title: 'home.next_visit_label'.tr(),
            value: nextVisitDate,
            valueColor: AppColors.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _StatCard(
            iconPath: SvgIcons.visitBorder,
            title: 'home.visits_count_label'.tr(),
            value: visitsCount,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String value;
  final Color? valueColor;

  const _StatCard({
    required this.iconPath,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundTint,
        border: Border.all(color: AppColors.greenMint, width: 0.3.r),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppShadows.profileItemShadow,
      ),
      child: Column(
        children: [
          SvgPicture.asset(iconPath, width: 60.w, height: 60.h),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyleManager.style14Bold.copyWith(
              color: valueColor ?? AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
