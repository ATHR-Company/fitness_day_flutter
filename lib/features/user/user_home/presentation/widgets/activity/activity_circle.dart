import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Diameter of the disc inside the progress ring. Fixed so the ring's centre
/// never resizes with the value; comfortably inside the 115 r ring minus its
/// 16 w stroke.
final double _kInnerDiscSize = 165.w;

// ─────────────────────────────────────────────────────────────────────────────
// Activity Circle (shared between walking & running)
// ─────────────────────────────────────────────────────────────────────────────

class ActivityCircle extends StatelessWidget {
  final double percent;
  final double currentVal;
  final double goalVal;
  final String unit;
  final int goalPercent;

  /// Decimal places for both values. Distances carry two; step counts are whole
  /// numbers, so walking passes zero.
  final int decimals;

  const ActivityCircle({
    super.key,
    required this.percent,
    required this.currentVal,
    required this.goalVal,
    required this.unit,
    required this.goalPercent,
    this.decimals = 0,
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
              // Fixed size, not padding-driven: sizing the inner disc from its
              // text made the whole circle swell and shrink as the step count
              // gained or lost digits. The values scale down to fit instead.
              center: Container(
                width: _kInnerDiscSize,
                height: _kInnerDiscSize,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundTint,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // A play/pause badge used to sit between these two, but it
                    // was driven by the activity type rather than the session
                    // and had no tap handler — a control that could never do
                    // anything. Running has a real start/stop button below.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currentVal.toStringAsFixed(decimals),
                        maxLines: 1,
                        style: TextStyleManager.style28Bold
                            .copyWith(color: AppColors.black),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '/ ${goalVal.toStringAsFixed(decimals)} $unit',
                        maxLines: 1,
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.greenMint, width: 1.r),
                    gradient: AppColors.timeRemainingGradient,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'activity_tracking.goal_percent'
                        .tr(args: ['$goalPercent']),
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
      ],
    );
  }
}
