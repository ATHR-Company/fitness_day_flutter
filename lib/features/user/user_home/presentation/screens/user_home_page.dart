import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/visit_card.dart';
import '../widgets/home_header.dart';
import '../widgets/section_header.dart';
import '../widgets/follow_up_alert_card.dart';
import '../../../../shared/widgets/app_drawer.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: AppColors.visitsBackgroundGradient.colors.first,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.dark,
            ),
          ),
        ),
        endDrawer: const AppDrawer(),
        body: Stack(
          children: [
            // Background split
            Column(
              children: [
                Container(
                  height: 220.h,
                  color: const Color(0xFFF1F8F1), // Light green top background
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFFAFAFA), // Light greyish background for the rest
                  ),
                ),
              ],
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header Area
                    const userHomeHeader(),

                    SizedBox(height: 24.h),

                    // Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 16.w),
                    //   child: const PerformanceSummarySection(),
                    // ),

                    SizedBox(height: 24.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        children: [
                          SectionHeader(
                            title: "home.upcoming_appointments".tr(),
                          ),
                          SizedBox(height: 16.h),
                          VisitCard(
                            timeRemaining: "home.commitment_rate".tr(args: ['85']),
                            title: "home.weekly_follow_up".tr(),
                            subtitle: "home.weekly_follow_up_desc".tr(),
                            clientName: "محمد عبدالله",
                            visitTime: "اليوم 4:30 مساءا",
                            location: "في مقر يوم الرشاقة",
                            buttonText: "home.view_visit".tr(),
                            onViewPressed: () {},
                            iconPath: SvgIcons.monitor,
                            secondaryButtonText: "home.reschedule".tr(),
                            onSecondaryPressed: () {},
                          ),

                          SizedBox(height: 24.h),

                          SectionHeader(
                            title: "home.todays_tasks".tr(),
                            trailing: GestureDetector(
                              onTap: () {
                                // TODO: Handle menu tap
                              },
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.more_horiz,
                                  color: AppColors.textPrimary,
                                  size: 24.w,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          VisitCard(
                            timeRemaining: "",
                            title: "home.measurements_review".tr(),
                            subtitle: "home.measurements_review_desc".tr(),
                            clientName: "محمد عبدالله",
                            visitTime: "10:30 مساءا  1/6/24",
                            location: "في مقر يوم الرشاقة",
                            buttonText: "home.previous_visit".tr(),
                            onViewPressed: () {},
                            iconPath: SvgIcons.measureReview,
                          ),
                          SizedBox(height: 16.h),
                          VisitCard(
                            timeRemaining: "",
                            title: "home.weekly_follow_up".tr(),
                            subtitle: "home.weekly_follow_up_desc".tr(),
                            clientName: "محمد عبدالله",
                            visitTime: "10:30 مساءا  1/6/24",
                            location: "في مقر يوم الرشاقة",
                            buttonText: "home.previous_visit".tr(),
                            onViewPressed: () {},
                            iconPath: SvgIcons.monitor, // User+ icon matching the design
                          ),

                          SizedBox(height: 24.h),

                          SectionHeader(
                            title: "home.clients_need_follow_up".tr(),
                            onMorePressed: () {
                              // TODO: Handle see more
                            },
                          ),
                          SizedBox(height: 16.h),
                          FollowUpAlertCard(
                            title: "home.needs_follow_up".tr(),
                            clientName: "محمد عبدالله",
                            alertReason: "home.low_commitment_alert".tr(),
                            buttonText: "home.review_plan".tr(),
                            iconPath: SvgIcons.needMonitorRed,
                            onButtonPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
