import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/date_badge.dart';

/// Title, participant count, goal text, and start/end date row shown below
/// the hero image on the active challenge screen.
class ChallengeHeaderInfo extends StatelessWidget {
  final ChallengeModel challenge;

  const ChallengeHeaderInfo({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.name,
                  style: TextStyleManager.style13Medium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              AppImage(
                SvgIcons.usersGroup,
                width: 16.w,
                height: 16.w,
                color: AppColors.primary,
              ),
              SizedBox(width: 4.w),
              Text(
                '${challenge.participantsCount}',
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '${'challenges.goal_prefix'.tr()}${challenge.goalLabel}',
            style: TextStyleManager.style10Medium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10.h),
          // Flexible: two badges plus a fixed gap overflow the row once the
          // system font grows them, and a date is not something to truncate.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: DateBadge(label: challenge.endLabel, isEnd: true),
              ),
              SizedBox(width: 16.w),
              Flexible(
                child: DateBadge(label: challenge.startLabel, isEnd: false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
