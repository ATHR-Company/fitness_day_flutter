import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Bottom sheet with report / share / end-challenge options, shown from the
/// active challenge screen's overflow menu.
class ChallengeOptionsSheet extends StatelessWidget {
  const ChallengeOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.greenMint, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OptionItem(
            label: 'challenges.option_report'.tr(),
            onTap: () => Navigator.pop(context),
          ),
          Divider(height: 1, color: AppColors.divider),
          _OptionItem(
            label: 'challenges.option_share'.tr(),
            onTap: () => Navigator.pop(context),
          ),
          Divider(height: 1, color: AppColors.divider),
          _OptionItem(
            label: 'challenges.option_end_challenge'.tr(),
            onTap: () => Navigator.pop(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionItem({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        child: Center(
          child: Text(
            label,
            style: TextStyleManager.style13Medium.copyWith(
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
