import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/task_card.dart';

/// "Previous achievements" section shown at the bottom of the active
/// challenge screen.
class ChallengePreviousAchievements extends StatelessWidget {
  const ChallengePreviousAchievements({super.key});

  List<TaskData> _buildAchievements(BuildContext context) => [
        TaskData(
          imagePath: SvgIcons.waterBorder,
          isSvgImage: true,
          title: 'home.hydration_title'.tr(),
          time: 'home.hydration_all_day'.tr(),
          description: 'home.hydration_desc'.tr(),
          extraLabel: '2.50 / 2.50',
          extraUnit: 'home.water_unit'.tr(),
          extraIcon: null,
          done: true,
        ),
        TaskData(
          imagePath: SvgIcons.waterBorder,
          isSvgImage: true,
          title: 'home.hydration_title'.tr(),
          time: 'home.hydration_all_day'.tr(),
          description: 'home.hydration_desc'.tr(),
          extraLabel: '2.50 / 2.50',
          extraUnit: 'home.water_unit'.tr(),
          extraIcon: null,
          done: true,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final achievements = _buildAchievements(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'challenges.previous_achievements_title'.tr(),
                style: TextStyleManager.heading3.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'challenges.see_more'.tr(),
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Directionality.of(context) == ui. TextDirection.rtl
                          ? Icons.keyboard_double_arrow_left_rounded
                          : Icons.keyboard_double_arrow_right_rounded,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...achievements.map(
            (task) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: TaskCard(task: task, plainBackground: true),
            ),
          ),
        ],
      ),
    );
  }
}
