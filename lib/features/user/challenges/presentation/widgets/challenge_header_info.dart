import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/domain/entities/challenge_model.dart';
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
                  challenge.title,
                  style: TextStyleManager.style13Medium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SvgPicture.asset(
                SvgIcons.usersGroup,
                width: 16.w,
                height: 16.w,
                colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              ),
              SizedBox(width: 4.w),
              Text(
                '${challenge.participants}',
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '${'challenges.goal_prefix'.tr()}${challenge.goal}',
            style: TextStyleManager.style10Medium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DateBadge(label: challenge.endDate, isEnd: true),
              SizedBox(width: 16.w),
              DateBadge(label: challenge.startDate, isEnd: false),
            ],
          ),
        ],
      ),
    );
  }
}
