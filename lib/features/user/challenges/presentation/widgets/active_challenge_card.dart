import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/domain/entities/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/date_badge.dart';

class ActiveChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback? onTap;

  const ActiveChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.borderGrey, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ChallengeImage(imageUrl: challenge.imageUrl),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleRow(
                    title: challenge.title,
                    participants: challenge.participants,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${'challenges.goal_label'.tr()}${challenge.goal}',
                    style: TextStyleManager.text2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DateBadge(label: challenge.startDate, isEnd: false),
                      SizedBox(width: 16.w),
                      DateBadge(label: challenge.endDate, isEnd: true),
                      const Spacer(),
                      Icon(
                        Directionality.of(context) ==ui. TextDirection.rtl
                            ? Icons.keyboard_double_arrow_left_rounded
                            : Icons.keyboard_double_arrow_right_rounded,
                        color: AppColors.primary,
                        size: 25.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeImage extends StatelessWidget {
  final String? imageUrl;

  const _ChallengeImage({this.imageUrl});

  static const _fallbackUrl =
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: Image.network(
        imageUrl ?? _fallbackUrl,
        height: 180.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, e, __) => Image.network(
          _fallbackUrl,
          height: 180.h,
          fit: BoxFit.cover,
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
        const Spacer(),
        SvgPicture.asset(
          SvgIcons.usersGroup,
          width: 16.w,
          height: 16.w,
          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
        SizedBox(width: 4.w),
        Text(
          '$participants',
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
