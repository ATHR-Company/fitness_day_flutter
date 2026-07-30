import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/summary_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Daily Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class DailySummaryCard extends StatelessWidget {
  /// Carries whatever unit [unit] names — kilometres for walking, the raw API
  /// figure for running — so it is never assumed to be kilometres here.
  final double distance;
  final String unit;

  /// Taken in seconds and displayed in minutes. The API reports fractional
  /// minutes (`0.9` for a 54-second walk), so keeping the precision this far and
  /// rounding once here is what stopped short sessions reading "0 دقيقة".
  final int durationSeconds;
  final int calories;
  final bool isWalking;

  /// Heading above the card. Defaults to the daily label; the weekly view
  /// passes its own so the same card serves both periods.
  final String? title;

  const DailySummaryCard({
    super.key,
    required this.distance,
    required this.unit,
    required this.durationSeconds,
    required this.calories,
    this.isWalking = false,
    this.title,
  });

  /// Whole minutes, rounded — and never rounded down to zero while time is
  /// actually being counted, since "0 دقيقة" next to a running clock reads as
  /// nothing being recorded.
  int get _durationMinutes {
    if (durationSeconds <= 0) return 0;
    final int rounded = (durationSeconds / 60).round();
    return rounded > 0 ? rounded : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? 'activity_tracking.day_summary'.tr(),
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 19.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.borderGrey),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SummaryItem(
                  icon: const Icon(Icons.local_fire_department_rounded,
                      color: Colors.deepOrangeAccent, size: 26),
                  label: 'activity_tracking.calories_label'.tr(),
                  value: '$calories',
                  unit: 'activity_tracking.calorie_unit'.tr(),
                ),
                SummaryItem(
                  icon: Icon(Icons.access_time_filled_rounded,
                      color: AppColors.surfaceGray, size: 26),
                  label: 'activity_tracking.elapsed_time'.tr(),
                  value: '$_durationMinutes',
                  unit: 'activity_tracking.minute_unit'.tr(),
                ),
                SummaryItem(
                  icon: const Icon(Icons.location_on_rounded,
                      color: Colors.pinkAccent, size: 26),
                  label: 'activity_tracking.distance_label'.tr(),
                  value: distance.toStringAsFixed(2),
                  unit: unit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
