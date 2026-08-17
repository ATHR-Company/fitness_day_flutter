import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

/// Header artwork of the challenge details dialog.
///
/// The tab switcher used to be stacked on top of this image, which put it
/// *before* the scrolling content in the dialog's Column — so the content was
/// painted over it and the challenge title slid across the tabs on scroll. The
/// two are composed separately by the dialog now, with the switcher last.
class ChallengeHeaderImage extends StatelessWidget {
  final String? imageUrl;

  /// How far the tab switcher hangs below this image. The dialog insets its
  /// scroll area by the same amount so nothing scrolls into that band.
  static double get overlap => 24.h;

  static double get height => 180.h;

  static const _fallbackUrl =
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400';

  const ChallengeHeaderImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return AppImage(
      imageUrl ?? _fallbackUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

/// The floating description/rules pill.
class ChallengeTabSwitcher extends StatelessWidget {
  final bool isDescriptionSelected;
  final ValueChanged<bool> onTabChanged;

  const ChallengeTabSwitcher({
    super.key,
    required this.isDescriptionSelected,
    required this.onTabChanged,
  });

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
