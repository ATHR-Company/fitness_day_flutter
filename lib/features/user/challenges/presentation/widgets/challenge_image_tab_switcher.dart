import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Challenge image with a floating description/rules tab switcher, shown in
/// the challenge details dialog.
class ChallengeImageTabSwitcher extends StatelessWidget {
  final String? imageUrl;
  final bool isDescriptionSelected;
  final ValueChanged<bool> onTabChanged;

  static const _fallbackUrl =
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400';

  const ChallengeImageTabSwitcher({
    super.key,
    this.imageUrl,
    required this.isDescriptionSelected,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Image.network(
          imageUrl ?? _fallbackUrl,
          height: 180.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: -24.h,
          child: _TabSwitcher(
            isDescriptionSelected: isDescriptionSelected,
            onTabChanged: onTabChanged,
          ),
        ),
      ],
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final bool isDescriptionSelected;
  final ValueChanged<bool> onTabChanged;

  const _TabSwitcher({required this.isDescriptionSelected, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.primary, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'challenges.tab_description'.tr(),
            isSelected: isDescriptionSelected,
            onTap: () => onTabChanged(true),
          ),
          _TabItem(
            label: 'challenges.tab_rules'.tr(),
            isSelected: !isDescriptionSelected,
            onTap: () => onTabChanged(false),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.challengeIconBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(24.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyleManager.style11Medium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
