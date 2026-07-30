import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

/// One selectable delivery method row — icon badge, label and radio dot.
///
/// Shared by the checkout step and the order review screen so both always show
/// the same icons and selection styling.
class DeliveryMethodOption extends StatelessWidget {
  final String title;

  /// SVG from [SvgIcons] — [SvgIcons.delivery] or [SvgIcons.branchPickup].
  final String iconPath;

  final bool isSelected;

  /// Null while the screen is busy, which also blocks the tap.
  final VoidCallback? onTap;

  const DeliveryMethodOption({
    super.key,
    required this.title,
    required this.iconPath,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.greenLightAccent
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: AppImage(
                iconPath,
                color: AppColors.white,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyleManager.style11Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            _SelectionDot(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  final bool isSelected;

  const _SelectionDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.textPlaceholder,
          width: isSelected ? 4 : 1,
        ),
      ),
    );
  }
}
