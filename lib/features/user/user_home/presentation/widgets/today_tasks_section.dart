import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Model
// ─────────────────────────────────────────────────────────────────────────────
class TaskData {
  final String imagePath;
  final String title;
  final String description;
  final String time;
  final String extraLabel;
  final String extraUnit;
  final IconData? extraIcon;
  final bool done;

  const TaskData({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.time,
    required this.extraLabel,
    required this.extraUnit,
    required this.extraIcon,
    required this.done,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Tasks List — default sample data
// ─────────────────────────────────────────────────────────────────────────────
class TodayTasksSection extends StatelessWidget {
  final List<TaskData> tasks;

  const TodayTasksSection({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tasks
          .map(
            (task) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: TaskCard(task: task),
            ),
          )
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task Card
// ─────────────────────────────────────────────────────────────────────────────
class TaskCard extends StatelessWidget {
  final TaskData task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
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
                Text(
                  task.title,
                  style: TextStyleManager.heading3.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time_filled,
                    size: 17.sp, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  task.time,
                  style: TextStyleManager.style10Medium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: task.done
                        ? AppColors.primary
                        : AppColors.inactiveGray,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: AppColors.white, size: 16.sp),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // ── Body ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular image
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: Border.all(color: AppColors.greenMint, width: 1.5),
                    image: DecorationImage(
                      image: NetworkImage(task.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
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

            SizedBox(height: 16.h),

            // ── Footer ──
            SizedBox(
              height: 38.h,
              child: ElevatedButton(
                onPressed: () {},
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
                    Icon(Icons.keyboard_double_arrow_left,
                        size: 16.sp, color: AppColors.white),
                  ],
                ),
              ),
            ),
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
          RichText(
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
        ],
      );
    }
    // sets style: "1 / 3"
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
            text: '  /  ${task.extraUnit}',
            style: TextStyleManager.style14Bold.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
