import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/scan_meal_screen.dart';
import 'package:fitness_day/features/user/challenges/presentation/screens/challenges_screen.dart';
import 'package:fitness_day/features/user/progress/presentation/pages/user_progress_page.dart';
import 'package:fitness_day/core/services/app_share_service.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(SvgIcons.muscle,      'home.category_challenges'.tr(), onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChallengesScreen()),
        );
      }),
      _Item(SvgIcons.achievement, 'home.category_progress'.tr(), onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserProgressPage()),
        );
      }),
      _Item(SvgIcons.barcode,     'home.category_calories'.tr(), onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanMealScreen()),
        );
      }),
      _Item(SvgIcons.share,       'home.category_share'.tr(), onTap: () {
        AppShareService.shareApp(context);
      }),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.map(_buildItem).toList(),
    );
  }

  Widget _buildItem(_Item item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
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
          child: AppImage(
            item.icon,
            color: AppColors.primary,
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
      ),
    );
  }
}

class _Item {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _Item(this.icon, this.label, {required this.onTap});
}
