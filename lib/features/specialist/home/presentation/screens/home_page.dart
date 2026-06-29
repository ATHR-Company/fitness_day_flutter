import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/visit_card.dart';
import '../widgets/home_header.dart';
import '../widgets/performance_summary_section.dart';
import '../widgets/section_header.dart';
import '../widgets/follow_up_alert_card.dart';
import '../../../../shared/widgets/app_drawer.dart';

import '../../../../shared/widgets/exit_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          showDialog(
            context: context,
            builder: (context) => const ExitDialog(),
          );
        },
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
                    color: AppColors
                        .homeTopBackground, // Light green top background
                  ),
                  Expanded(
                    child: Container(
                      color: AppColors
                          .scaffoldBackground, // Light greyish background for the rest
                    ),
                  ),
                ],
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Area
                      const HomeHeader(),

                      SizedBox(height: 24.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: const PerformanceSummarySection(),
                      ),

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
                              timeRemaining: "home.commitment_rate".tr(
                                args: ['85'],
                              ),
                              title: "home.weekly_follow_up".tr(),
                              subtitle: "home.weekly_follow_up_desc".tr(),
                              clientName: 'spec_mock_name'.tr(),
                              visitTime: 'spec_mock_time3'.tr(),
                              location: 'spec_mock_location'.tr(),
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
                              clientName: 'spec_mock_name'.tr(),
                              visitTime: 'spec_mock_time4'.tr(),
                              location: 'spec_mock_location'.tr(),
                              buttonText: "home.previous_visit".tr(),
                              onViewPressed: () {},
                              iconPath: SvgIcons.measureReview,
                            ),
                            SizedBox(height: 16.h),
                            VisitCard(
                              timeRemaining: "",
                              title: "home.weekly_follow_up".tr(),
                              subtitle: "home.weekly_follow_up_desc".tr(),
                              clientName: 'spec_mock_name'.tr(),
                              visitTime: 'spec_mock_time4'.tr(),
                              location: 'spec_mock_location'.tr(),
                              buttonText: "home.previous_visit".tr(),
                              onViewPressed: () {},
                              iconPath: SvgIcons
                                  .monitor, // User+ icon matching the design
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
                              clientName: 'spec_mock_name'.tr(),
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
      ),
    );
  }
}
