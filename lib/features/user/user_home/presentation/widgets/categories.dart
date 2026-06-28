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
    final categories = [
      _CategoryItem(icon: SvgIcons.muscle, label: 'التحديات'),
      _CategoryItem(icon: SvgIcons.achievement, label: 'التقدم'),
      _CategoryItem(icon: SvgIcons.barcode, label: 'السعرات'),
      _CategoryItem(icon: SvgIcons.share, label: 'مشاركة'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: categories
          .map((item) => _buildCategoryItem(item))
          .toList(),
    );
  }

  Widget _buildCategoryItem(_CategoryItem item) {
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
                color: Colors.black.withValues(alpha: 0.10),
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

class _CategoryItem {
  final String icon;
  final String label;
  const _CategoryItem({required this.icon, required this.label});
}
