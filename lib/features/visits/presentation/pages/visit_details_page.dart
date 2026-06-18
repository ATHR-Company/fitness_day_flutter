import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/features/visits/presentation/widgets/reschedule_visit_dialog.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';

class VisitDetailsPage extends StatefulWidget {
  const VisitDetailsPage({super.key});

  @override
  State<VisitDetailsPage> createState() => _VisitDetailsPageState();
}

class _VisitDetailsPageState extends State<VisitDetailsPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.visitsBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // 1. Back Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppBackHeader(
                  title: 'visit_details.title'.tr(),
                ),
              ),

              SizedBox(height: 32.h),

              // 2. Segmented Control (3 tabs) — reversed so first tab is on the right (RTL)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppSegmentedControl(
                  type: AppSegmentedControlType.unified,
                  items: [
                    'visit_details.tab_visit_data'.tr(),
                    'visit_details.tab_report'.tr(),
                    'visit_details.tab_custom_plan'.tr(),
                  ],
                  selectedIndex: _selectedTabIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                ),
              ),

              SizedBox(height: 24.h),

              // 3. Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: _buildTabContent(),
                ),
              ),

              // 4. Bottom Buttons
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: Row(
                  children: [
                    // Start Visit (Primary) — on the right in RTL
                    Expanded(
                      child: CustomButton(
                        text: 'visit_details.start_visit'.tr(),
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Reschedule (Outlined) — on the left in RTL
                    Expanded(
                      child: CustomOutlinedButton(
                        text: 'visit_details.reschedule'.tr(),
                        onPressed: () {
                          showRescheduleDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildVisitDataTab();
      case 1:
        return _buildReportTab();
      case 2:
        return _buildCustomPlanTab();
      default:
        return _buildVisitDataTab();
    }
  }

  Widget _buildVisitDataTab() {
    return Column(
      children: [
        // Visit Card
        VisitCard(
          timeRemaining: 'visits.in_minutes'.tr(args: ['25']),
          title: 'visits.dummy_title'.tr(),
          subtitle: 'visits.dummy_subtitle'.tr(),
          clientName: 'visits.dummy_client'.tr(),
          visitTime: '${'visits.today'.tr()} 4:30 ${'visits.pm'.tr()}',
          location: 'visits.hq_location'.tr(),
          onViewPressed: () {},
        ),

        SizedBox(height: 16.h),

        // Visit Goal Card
        VisitGoalCard(
          title: 'visit_details.visit_goal_title'.tr(),
          goals: [
            'visit_details.goal_1'.tr(),
            'visit_details.goal_2'.tr(),
            'visit_details.goal_3'.tr(),
            'visit_details.goal_4'.tr(),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomPlanTab() {
    return const SizedBox.shrink();
  }

  Widget _buildReportTab() {
    return const SizedBox.shrink();
  }
}
