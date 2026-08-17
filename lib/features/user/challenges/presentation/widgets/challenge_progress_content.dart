import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';

/// Progress ring for the active challenge screen. Metric-agnostic: it reads
/// progress, goal and unit off the challenge, so it serves steps, kilometres,
/// calories and millilitres alike.
class ChallengeProgressContent extends StatelessWidget {
  final ChallengeModel challenge;

  /// What to draw, which during a session is the server's progress plus what
  /// the session has added since it started. Defaults to the challenge's own
  /// figure when no session is running.
  final double? progress;

  /// The matching fraction. Passed in rather than derived here so the badge
  /// over the hero image and this ring are guaranteed to be the same number.
  final double? fraction;

  final bool isTracking;

  /// Null disables the button — a completed or expired challenge has nothing
  /// left to track.
  final VoidCallback? onToggle;

  const ChallengeProgressContent({
    super.key,
    required this.challenge,
    this.progress,
    this.fraction,
    this.isTracking = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final double current = progress ?? challenge.progress;
    // The server's own percentage is the fallback, not the primary: during a
    // session it sits still while the local figure keeps moving.
    final double fraction = this.fraction ?? challenge.progressFraction;

    return Column(
      children: [
        SizedBox(height: 8.h),
        // Every number is the challenge's own. These were defaulted constants
        // (2500 of 5000, 44%) that the widget showed for whichever challenge it
        // was given, so the ring never matched what the user had actually done.
        _StepsCircularIndicator(
          percent: fraction,
          current: current,
          goal: challenge.goal,
          goalPercent: (fraction * 100).round(),
          unit: challenge.unit,
          isTracking: isTracking,
          onToggle: onToggle,
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

  /// Already translated by the backend — "خطوة", "كم", "مل". Never built from
  /// the metric here.
  final String unit;

  final bool isTracking;
  final VoidCallback? onToggle;

  const _StepsCircularIndicator({
    required this.percent,
    required this.current,
    required this.goal,
    required this.goalPercent,
    required this.unit,
    required this.isTracking,
    this.onToggle,
  });

  /// Distance reads in kilometres and needs its decimals; steps, calories and
  /// millilitres are whole numbers, and "5.00 km" vs "7480 steps" is the same
  /// distinction the plan's screens make.
  String get _currentLabel =>
      current < 100 && current != current.roundToDouble()
          ? current.toStringAsFixed(2)
          : current.toStringAsFixed(0);

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
              // A fixed inner disc rather than `padding: EdgeInsets.all(45.w)`
              // around the content. That padding made the disc's size follow
              // its text, so a large system font grew it past the ring while
              // "/ 70000 steps" wrapped onto a second line. The size is now
              // independent of the text, and the FittedBox below shrinks the
              // content to fit instead of the disc growing to hold it.
              center: SizedBox(
                width: 180.r,
                height: 180.r,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundTint,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentLabel,
                            maxLines: 1,
                            style: TextStyleManager.style28Bold
                                .copyWith(color: AppColors.black),
                          ),
                          SizedBox(height: 6.h),
                          // Was a bare Icon with no gesture at all, so the ring
                          // looked like it offered a session it could not start.
                          GestureDetector(
                            onTap: onToggle,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: onToggle == null
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isTracking
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.white,
                                size: 18.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '/ ${goal.toStringAsFixed(0)} $unit',
                            // One line on purpose: the FittedBox scales the
                            // whole block down rather than letting the unit
                            // drop onto its own row.
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyleManager.style11Medium
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                  // Bounded by the ring's width, so a long label scales
                  // instead of pushing the pill past the ring.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'challenges.goal_percent_label'.tr(args: ['$goalPercent']),
                      maxLines: 1,
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.greenDarkAccent,
                        fontWeight: FontWeight.bold,
                      ),
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
