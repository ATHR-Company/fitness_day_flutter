import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/date_badge.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

class SuggestedChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback? onTap;

  const SuggestedChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.suggestedCardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderGrey, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const _TrophyIcon(),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleRow(
                    title: challenge.name,
                    participants: challenge.participantsCount,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    challenge.goalLabel,
                    style: TextStyleManager.style10Medium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Start before end, matching the active card. They were
                  // reversed here, so the two cards on the same screen read
                  // their dates in opposite orders.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: DateBadge(
                          label: challenge.startLabel,
                          isEnd: false,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: DateBadge(
                          label: challenge.endLabel,
                          isEnd: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 38.w,
              height: 38.w,
              child: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.keyboard_double_arrow_left_rounded
                    : Icons.keyboard_double_arrow_right_rounded,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrophyIcon extends StatelessWidget {
  const _TrophyIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppImage(
          AppImages.challenge_cap,
          width: 40.w,
          height: 40.w,
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final String title;
  final int participants;

  const _TitleRow({required this.title, required this.participants});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded, not a bare Text: the name is the only part of this row that
        // can vary in width, so it is what has to give. Without it the title
        // took its natural width and shoved the count and icon off the card —
        // which is exactly what a long name at a large font did.
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyleManager.style13Medium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Text(
          '$participants',
          style: TextStyleManager.style10Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 4.w),
        AppImage(
          SvgIcons.usersGroup,
          width: 14.w,
          height: 14.w,
          color: AppColors.primary,
        ),
      ],
    );
  }
}
