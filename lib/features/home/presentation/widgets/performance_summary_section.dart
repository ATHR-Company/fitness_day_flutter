import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constant/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'stat_card.dart';

class PerformanceSummarySection extends StatelessWidget {
  const PerformanceSummarySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background graphic/gradient at the bottom (approximating the green shape)
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 60.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.greenSoftTint,
                      AppColors.primary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "home.performance_summary_title".tr(),
                  style: TextStyleManager.heading2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    StatCard(
                      title: "home.clients_count".tr(),
                      value: "15",
                      iconPath: SvgIcons.clientsNumber,
                    ),
                    SizedBox(width: 8.w),
                    StatCard(
                      title: "home.needs_follow_up".tr(),
                      value: "5",
                      iconPath: SvgIcons.needMonitor,
                    ),
                    SizedBox(width: 8.w),
                    StatCard(
                      title: "home.todays_visits".tr(),
                      value: "2",
                      iconPath: SvgIcons.todaysVisit,
                      isPrimary: true,
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
