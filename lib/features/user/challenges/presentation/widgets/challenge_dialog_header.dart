import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Header of the challenge details dialog: close button + centered title.
class ChallengeDialogHeader extends StatelessWidget {
  final VoidCallback onClose;

  const ChallengeDialogHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.challengeIconBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close_rounded, color: AppColors.primary, size: 30.sp),
          ),
          const Spacer(),
          Text(
            'challenges.details_title'.tr(),
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          SizedBox(width: 28.sp),
        ],
      ),
    );
  }
}
