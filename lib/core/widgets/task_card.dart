import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:go_router/go_router.dart';

import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/exercise_details_dialog.dart';

class TaskCard extends StatelessWidget {
  final TaskData task;
  final bool plainBackground;

  const TaskCard({
    super.key,
    required this.task,
    this.plainBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: plainBackground ? null : AppColors.cardGradient,
        color: plainBackground ? AppColors.white : null,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(4.r),
          topEnd: Radius.circular(4.r),
          bottomStart: Radius.circular(4.r),
          bottomEnd: Radius.circular(32.r),
        ),
        border: Border.all(color: AppColors.greenMint, width: 0.5),
        boxShadow: AppShadows.profileItemShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Header ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 8.w),
                    AppImage(
                      SvgIcons.clock,
                      width: 17.w,
                      height: 17.h,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      task.time,
                      style: TextStyleManager.style10Medium.copyWith(
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: task.done ? AppColors.primary : AppColors.divider,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: AppColors.white, size: 16.sp),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // ── Body ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular image
                AppImage(
                  task.imagePath,
                  width: 72.w,
                  height: 72.w,
                  fit: BoxFit.cover,
                  radius: 36.r,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.description,
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _buildExtra(),
                    ],
                  ),
                ),
              ],
            ),

            if (task.onDetailsPressed != null || task.isExerciseDialog || task.route != null) ...[
              SizedBox(height: 16.h),
              // ── Footer ──
              SizedBox(
                height: 38.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (task.onDetailsPressed != null) {
                      task.onDetailsPressed!();
                    } else if (task.isExerciseDialog) {
                      showDialog(
                        context: context,
                        builder: (_) => ExerciseDetailsDialog(
                          workoutItemId: task.workoutItemId,
                          dayNumber: task.workoutDayNumber,
                        ),
                      );
                    } else if (task.route != null) {
                      context.push(task.route!, extra: task.routeExtra);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'home.details_button'.tr(),
                        style: TextStyleManager.style12Regular.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Directionality.of(context) == ui.TextDirection.rtl
                          ? Icons.keyboard_double_arrow_left_rounded
                          : Icons.keyboard_double_arrow_right_rounded,
                          size: 16.sp, color: AppColors.white),
                    ],
                  ),                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExtra() {
    if (task.extraIcon != null) {
      // calories style
      return Row(
        children: [
          Icon(task.extraIcon, color: AppColors.primary, size: 16.sp),
          SizedBox(width: 4.w),
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: task.extraLabel,
                    style: TextStyleManager.text2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '  ${task.extraUnit}',
                    style: TextStyleManager.style13Medium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    // sets style: "0 / 3" — extraLabel is green (completed), extraUnit is gray (total)
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: task.extraLabel,
            style: TextStyleManager.style14Bold.copyWith(
              color: AppColors.primary,
            ),
          ),
          TextSpan(
            text: ' / ',
            style: TextStyleManager.style14Bold.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          TextSpan(
            text: task.extraUnit,
            style: TextStyleManager.style14Bold.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
