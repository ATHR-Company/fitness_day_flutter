import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/date_badge.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

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
            _ChallengeImage(imageUrl: challenge.image),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleRow(
                    title: challenge.name,
                    participants: challenge.participantsCount,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${'challenges.goal_label'.tr()}${challenge.goalLabel}',
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
                      DateBadge(label: challenge.startLabel, isEnd: false),
                      SizedBox(width: 16.w),
                      DateBadge(label: challenge.endLabel, isEnd: true),
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

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl;
    final bool hasArtwork = url != null && url.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: SizedBox(
        height: 180.h,
        width: double.infinity,
        // `image` is null until an admin uploads artwork, which is the normal
        // state for a freshly created challenge — so the empty case needs a
        // deliberate design, not a stand-in. This used to point at a hardcoded
        // Unsplash food photo, so every artwork-less challenge rendered the
        // same stock salad: wrong for a step goal, fetched from a third party,
        // and indistinguishable from a real image the admin had chosen.
        child: hasArtwork
            ? AppImage(url, height: 180.h, width: double.infinity,
                fit: BoxFit.cover)
            : ColoredBox(
                color: AppColors.backgroundTint,
                child: Center(
                  child: AppImage(
                    AppImages.challenge_cap,
                    height: 84.h,
                    fit: BoxFit.contain,
                  ),
                ),
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
        AppImage(
          SvgIcons.usersGroup,
          width: 16.w,
          height: 16.w,
          color: AppColors.primary,
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
