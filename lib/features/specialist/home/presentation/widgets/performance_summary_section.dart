import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'stat_card.dart';

class PerformanceSummarySection extends StatelessWidget {
  final int dailyVisitsCount;
  final int needsFollowUpCount;
  final int clientsCount;

  const PerformanceSummarySection({
    super.key,
    required this.dailyVisitsCount,
    required this.needsFollowUpCount,
    required this.clientsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Stack(
        children: [
          // Background graphic/gradient wave
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
              child: AppImage(
                SvgIcons.performanceCardGradient,
                fit: BoxFit.fitWidth,
                //alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "home.performance_summary_title".tr(),
                  style: TextStyleManager.style14Medium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: StatCard(
                        title: "home.todays_visits".tr(),
                        value: dailyVisitsCount.toString(),
                        iconPath: SvgIcons.todaysVisit,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: StatCard(
                        title: "home.needs_follow_up".tr(),
                        value: needsFollowUpCount.toString(),
                        iconPath: SvgIcons.needMonitor,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: StatCard(
                        title: "home.clients_count".tr(),
                        value: clientsCount.toString(),
                        iconPath: SvgIcons.clientsNumber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
