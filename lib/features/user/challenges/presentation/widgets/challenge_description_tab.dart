import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/date_badge.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

/// "Description" tab content of the challenge details dialog.
/// Scrolling content only — the join / next actions are pinned to the bottom of
/// the sheet by [ChallengeDetailsDialog] so they hold one position across both
/// tabs instead of following each tab's content height.
class ChallengeDescriptionTab extends StatelessWidget {
  final ChallengeModel challenge;

  const ChallengeDescriptionTab({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40.h),
        Container(
          width: 56.w,
          height: 56.w,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Center(
            child: AppImage(AppImages.challenge_cap, width: 40.w, height: 40.w),
          ),
        ),
        SizedBox(height: 16.h),
        // The challenge's own name — the sheet used to show only the goal, so
        // every challenge's description tab looked the same.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            challenge.name,
            textAlign: TextAlign.center,
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '${'challenges.goal_prefix'.tr()}${challenge.goalLabel}',
          style: TextStyleManager.style10Medium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DateBadge(label: challenge.endLabel, isEnd: true),
            SizedBox(width: 32.w),
            DateBadge(label: challenge.startLabel, isEnd: false),
          ],
        ),
        SizedBox(height: 24.h),
        Text(
          'challenges.description_label'.tr(),
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          // The server's description, already in the requested language. This
          // was a fixed translation key, so the same paragraph appeared under
          // every challenge no matter what it was.
          child: Text(
            challenge.description,
            textAlign: TextAlign.center,
            style: TextStyleManager.style10Medium.copyWith(color: AppColors.textSecondary),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
