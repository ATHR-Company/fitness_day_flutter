import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/domain/entities/challenge_model.dart';

/// Circular steps-progress indicator shown on the active challenge screen
/// for step-based challenges.
class ChallengeStepsContent extends StatelessWidget {
  final ChallengeModel challenge;
  final double current;
  final double goal;
  final int goalPercent;

  const ChallengeStepsContent({
    super.key,
    required this.challenge,
    this.current = 2500,
    this.goal = 5000,
    this.goalPercent = 44,
  });

  double get _percent => (current / goal).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        _StepsCircularIndicator(
          percent: _percent,
          current: current,
          goal: goal,
          goalPercent: goalPercent,
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}

class _StepsCircularIndicator extends StatelessWidget {
  final double percent;
  final double current;
  final double goal;
  final int goalPercent;

  const _StepsCircularIndicator({
    required this.percent,
    required this.current,
    required this.goal,
    required this.goalPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            CircularPercentIndicator(
              radius: 115.r,
              lineWidth: 16.w,
              percent: percent,
              startAngle: 220,
              backgroundColor: AppColors.backgroundTint,
              progressColor: AppColors.greenLightAccent,
              circularStrokeCap: CircularStrokeCap.round,
              center: Container(
                padding: EdgeInsets.all(45.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundTint,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      current.toStringAsFixed(0),
                      style: TextStyleManager.style28Bold.copyWith(color: AppColors.black),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.play_arrow_rounded, color: AppColors.white, size: 18.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '/ ${goal.toStringAsFixed(0)} ${'challenges.steps_unit'.tr()}',
                      style: TextStyleManager.style11Medium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greenMint, width: 1),
                    gradient: AppColors.timeRemainingGradient,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'challenges.goal_percent_label'.tr(args: ['$goalPercent']),
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.greenDarkAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
