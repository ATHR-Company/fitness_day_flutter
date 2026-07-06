import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';

import '../../../visits/presentation/pages/visit_details_page.dart';

class TodayTasksPage extends StatelessWidget {
  const TodayTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.profileGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        endDrawer: const AppDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'drawer.today_tasks'.tr()),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(20.h),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: VisitCard(
                        isUpcoming: true,
                        timeRemaining: '', // No badge
                        title: 'home.weekly_follow_up'.tr(),
                        subtitle: 'home.weekly_follow_up_desc'.tr(),
                        personName: 'spec_mock_name'.tr(),
                        visitTime: 'spec_mock_time3'.tr(),
                        location: 'spec_mock_location'.tr(),
                        buttonText: 'home.view_visit'.tr(),
                        onViewPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VisitDetailsPage(isUpcoming: true),
                            ),
                          );
                        },
                        secondaryButtonText: 'home.reschedule'.tr(),
                        onSecondaryPressed: () {},
                        iconPath: SvgIcons.needMonitor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
