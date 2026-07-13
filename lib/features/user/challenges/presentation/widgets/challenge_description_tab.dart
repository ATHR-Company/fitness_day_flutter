import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/domain/entities/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/date_badge.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

/// "Description" tab content of the challenge details dialog.
class ChallengeDescriptionTab extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback onNext;

  const ChallengeDescriptionTab({super.key, required this.challenge, required this.onNext});

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
        Text(
          '${'challenges.goal_prefix'.tr()}${challenge.goal}',
          style: TextStyleManager.style10Medium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DateBadge(label: challenge.endDate, isEnd: true),
            SizedBox(width: 32.w),
            DateBadge(label: challenge.startDate, isEnd: false),
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
          child: Text(
            'challenges.description_body'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.style10Medium.copyWith(color: AppColors.textSecondary),
          ),
        ),
        SizedBox(height: 32.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
              elevation: 0,
            ),
            child: Text(
              'challenges.btn_next'.tr(),
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
