import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/domain/entities/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/date_badge.dart';

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
                    title: challenge.title,
                    participants: challenge.participants,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    challenge.goal,
                    style: TextStyleManager.style10Medium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DateBadge(label: challenge.endDate, isEnd: true),
                      DateBadge(label: challenge.startDate, isEnd: false),
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
        child: Image.asset(
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
        Text(
          title,
          style: TextStyleManager.style13Medium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
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
        SvgPicture.asset(
          SvgIcons.usersGroup,
          width: 14.w,
          height: 14.w,
          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
      ],
    );
  }
}
