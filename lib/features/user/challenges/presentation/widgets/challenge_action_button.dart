import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';

/// Join, leave, or nothing at all — the challenge's one action.
///
/// Shared by both tabs of the details sheet so the two can never disagree about
/// what the challenge currently allows. A finished challenge and one whose
/// dates have passed both have no action left: offering "join" on either would
/// only earn a rejection from the server.
class ChallengeActionButton extends StatelessWidget {
  final ChallengeModel challenge;

  /// True while a join or leave is in flight.
  final bool isBusy;

  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const ChallengeActionButton({
    super.key,
    required this.challenge,
    required this.onJoin,
    required this.onLeave,
    this.isBusy = false,
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
          // Shrinks rather than truncating: "Leave challenge" is long, and in a
          // half-width slot beside another button it clipped to "Leave chal…".
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isJoined
                    ? 'challenges.btn_leave'.tr()
                    : 'challenges.btn_join'.tr(),
                maxLines: 1,
                style: TextStyleManager.style13Medium.copyWith(
                  color: isJoined ? AppColors.error : AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyleManager.style13Medium.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
