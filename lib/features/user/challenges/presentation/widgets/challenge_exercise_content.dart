import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/week_date_picker.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';

/// Week day picker + "today's exercise" card shown on the active challenge
/// screen for exercise-based challenges.
class ChallengeExerciseContent extends StatefulWidget {
  final ChallengeModel challenge;
  final int dayOfChallenge;

  const ChallengeExerciseContent({
    super.key,
    required this.challenge,
    this.dayOfChallenge = 3,
  });

  @override
  State<ChallengeExerciseContent> createState() => _ChallengeExerciseContentState();
}

class _ChallengeExerciseContentState extends State<ChallengeExerciseContent> {
  int _selectedDayIndex = 2;

  static const _dayKeys = ['sat', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri'];
  static const _dates = ['14', '15', '16', '17', '18', '19', '20'];
  static const _doneDays = <int>{0, 1};

  @override
  Widget build(BuildContext context) {
    final days = _dayKeys.map((key) => 'common.weekdays.$key'.tr()).toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeekDatePicker(
            days: days,
            dates: _dates,
            selectedIndex: _selectedDayIndex,
            doneDayIndices: _doneDays,
            onDaySelected: (i) => setState(() => _selectedDayIndex = i),
          ),
          SizedBox(height: 24.h),
          _TodayExerciseCard(dayOfChallenge: widget.dayOfChallenge),
        ],
      ),
    );
  }
}

class _TodayExerciseCard extends StatelessWidget {
  final int dayOfChallenge;

  const _TodayExerciseCard({required this.dayOfChallenge});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'challenges.today_exercise_title'.tr(),
              style: TextStyleManager.heading3.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.w),
            Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 16.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  'challenges.day_of_challenge'.tr(args: ['$dayOfChallenge']),
                  style: TextStyleManager.style10Medium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1),
            gradient: AppColors.cardGradient,
          ),
          child: Row(
            children: [
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  'challenges.start_exercise_prompt'.tr(),
                  style: TextStyleManager.style11Medium.copyWith(color: AppColors.textSecondary),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'challenges.start_now'.tr(),
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Directionality.of(context) == ui. TextDirection.rtl
                          ? Icons.keyboard_double_arrow_left_rounded
                          : Icons.keyboard_double_arrow_right_rounded,
                      color: AppColors.white,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
