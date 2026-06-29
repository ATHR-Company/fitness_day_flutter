import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(SvgIcons.muscle,      'home.category_challenges'.tr()),
      _Item(SvgIcons.achievement, 'home.category_progress'.tr()),
      _Item(SvgIcons.barcode,     'home.category_calories'.tr()),
      _Item(SvgIcons.share,       'home.category_share'.tr()),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.map(_buildItem).toList(),
    );
  }

  Widget _buildItem(_Item item) {
    return Column(
      children: [
        Container(
          height: 56.h,
          width: 56.w,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.14),
                blurRadius: 10.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SvgPicture.asset(
            item.icon,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          item.label,
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _Item {
  final String icon;
  final String label;
  const _Item(this.icon, this.label);
}
