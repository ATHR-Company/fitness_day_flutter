import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constant/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'stat_card.dart';

class PerformanceSummarySection extends StatelessWidget {
  const PerformanceSummarySection({super.key});

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
              child: SvgPicture.asset(
                SvgIcons.performanceCardGradient,
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
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
                  style: TextStyleManager.heading2.copyWith(
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
                        value: "2",
                        iconPath: SvgIcons.todaysVisit,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: StatCard(
                        title: "home.needs_follow_up".tr(),
                        value: "5",
                        iconPath: SvgIcons.needMonitor,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: StatCard(
                        title: "home.clients_count".tr(),
                        value: "15",
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
