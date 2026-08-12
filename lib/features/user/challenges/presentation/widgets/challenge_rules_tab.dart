import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';

/// "Rules" tab of the challenge details dialog, ending with the join or leave
/// action.
///
/// The rules are the server's — `GET /challenges/:id` returns them already
/// translated to the requested language. They used to be five hardcoded keys,
/// which meant every challenge showed the same five sentences no matter what it
/// actually asked of the user.
class ChallengeRulesTab extends StatelessWidget {
  final ChallengeModel challenge;

  /// True while a join or leave is in flight.
  final bool isBusy;

  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const ChallengeRulesTab({
    super.key,
    required this.challenge,
    required this.onJoin,
    required this.onLeave,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32.h),
        if (challenge.rules.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'challenges.no_rules'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ...challenge.rules.map((rule) => _RuleItem(text: rule)),
        SizedBox(height: 32.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: _ActionButton(
            challenge: challenge,
            isBusy: isBusy,
            onJoin: onJoin,
            onLeave: onLeave,
          ),
        ),
      ],
    );
  }
}

/// Join, leave, or nothing at all.
///
/// A finished challenge and one whose dates have passed both have no action
/// left — offering "join" on either would only produce a rejection from the
/// server.
class _ActionButton extends StatelessWidget {
  final ChallengeModel challenge;
  final bool isBusy;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _ActionButton({
    required this.challenge,
    required this.isBusy,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    if (challenge.isCompleted) {
      return _StatusPill(
        label: 'challenges.completed'.tr(),
        color: AppColors.primary,
      );
    }

    if (challenge.status == ChallengeStatus.ended) {
      return _StatusPill(
        label: 'challenges.ended'.tr(),
        color: AppColors.textSecondary,
      );
    }

    final bool isJoined = challenge.isJoined;

    return ElevatedButton(
      onPressed: isBusy ? null : (isJoined ? onLeave : onJoin),
      style: ElevatedButton.styleFrom(
        backgroundColor: isJoined ? AppColors.white : AppColors.primary,
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
          side: BorderSide(
            color: isJoined ? AppColors.error : Colors.transparent,
          ),
        ),
        elevation: 0,
      ),
      child: isBusy
          ? SizedBox(
              width: 20.r,
              height: 20.r,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Text(
              isJoined
                  ? 'challenges.btn_leave'.tr()
                  : 'challenges.btn_join'.tr(),
              style: TextStyleManager.style13Medium.copyWith(
                color: isJoined ? AppColors.error : AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Text(
        label,
        style: TextStyleManager.style13Medium.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String text;

  const _RuleItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(Icons.radio_button_checked,
                color: AppColors.primary, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
