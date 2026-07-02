import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/features/specialist/home/presentation/widgets/home_header.dart';
import 'package:fitness_day/features/specialist/home/presentation/widgets/performance_summary_section.dart';
import 'package:fitness_day/features/specialist/home/presentation/widgets/section_header.dart';
import 'package:fitness_day/features/specialist/home/presentation/widgets/follow_up_alert_card.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';
import 'package:fitness_day/features/specialist/visits/presentation/pages/visit_details_page.dart';

import 'package:fitness_day/core/widgets/exit_dialog.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
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
            backgroundColor: AppColors.headerBackground,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.dark,
            ),
          ),
        ),
        endDrawer: const AppDrawer(),
        body: SafeArea(
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
                        personName: 'spec_mock_name'.tr(),
                        visitTime: 'spec_mock_time3'.tr(),
                        location: 'spec_mock_location'.tr(),
                        buttonText: "home.view_visit".tr(),
                        onViewPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VisitDetailsPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SectionHeader(
                        title: "home.todays_tasks".tr(),
                        onMorePressed: () {},
                      ),
                      SizedBox(height: 16.h),
                      VisitCard(
                        timeRemaining: "",
                        title: "home.measurements_review".tr(),
                        subtitle: "home.measurements_review_desc".tr(),
                        personName: 'spec_mock_name'.tr(),
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
                        personName: 'spec_mock_name'.tr(),
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
      ),
    );
  }
}
