import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

class VisitLogPage extends StatefulWidget {
  const VisitLogPage({super.key});

  @override
  State<VisitLogPage> createState() => _VisitLogPageState();
}

class _VisitLogPageState extends State<VisitLogPage> {
  int selectedDateIndex = 2; // For mock data

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBackground,
      endDrawer: const UserAppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: LocaleKeys.drawer_visits_log.tr(),
              onMenuPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Picker (Mock)
                    _buildDatePicker(),
                    SizedBox(height: 32.h),

                    // Upcoming Visit
                    Text(
                      LocaleKeys.home_upcoming_appointments.tr(),
                      style: TextStyleManager.heading3.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildUpcomingVisitCard(),

                    SizedBox(height: 32.h),

                    // Previous Visits
                    Text(
                      LocaleKeys.clients_page_past_visits.tr(),
                      style: TextStyleManager.heading3.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildPreviousVisitCard(),
                    SizedBox(height: 16.h),
                    _buildPreviousVisitCard(), // duplicate for effect
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final days = [
      LocaleKeys.visit_details_day_1.tr(),
      LocaleKeys.visit_details_day_2.tr(),
      LocaleKeys.visit_details_day_3.tr(),
      LocaleKeys.visit_details_day_4.tr(),
      LocaleKeys.visit_details_day_5.tr(),
      LocaleKeys.visit_details_day_6.tr(),
      LocaleKeys.visit_details_day_7.tr(),
    ];
    final dates = ['14', '15', '16', '17', '18', '19', '20'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (index) {
        final isSelected = index == selectedDateIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedDateIndex = index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                Text(
                  days[index],
                  style: TextStyleManager.style11Medium.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  dates[index],
                  style: TextStyleManager.style14Bold.copyWith(
                    color: isSelected ? AppColors.white : AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        );
      }),
    );
  }

  Widget _buildUpcomingVisitCard() {
    return Stack(
      children: [
        VisitCard(
          timeRemaining: '',
          title: LocaleKeys.home_weekly_follow_up.tr(),
          subtitle: LocaleKeys.home_weekly_follow_up_desc.tr(),
          personName: LocaleKeys.spec_mock_name.tr(),
          personNameLabel: LocaleKeys.visits_client_name_label.tr(),
          visitTime: '${LocaleKeys.visits_today.tr()} 4:30 ${LocaleKeys.visits_pm.tr()}',
          location: LocaleKeys.visits_hq_location.tr(),
          buttonText: LocaleKeys.home_view_visit.tr(),
          iconPath: SvgIcons.monitor,
          iconColor: Colors.grey,
          isUpcoming: true,
          onViewPressed: () {
            context.push(UserAppRoutes.upcomingVisitShow);
          },
        ),
      ],
    );
  }

  Widget _buildPreviousVisitCard() {
    return Stack(
      children: [
        VisitCard(
          timeRemaining: '',
          title: LocaleKeys.home_weekly_follow_up.tr(),
          subtitle: LocaleKeys.home_weekly_follow_up_desc.tr(),
          personName: LocaleKeys.spec_mock_name.tr(),
          personNameLabel: LocaleKeys.visits_client_name_label.tr(),
          visitTime: '${LocaleKeys.visits_today.tr()} 4:30 ${LocaleKeys.visits_pm.tr()}',
          location: LocaleKeys.visits_hq_location.tr(),
          buttonText: LocaleKeys.home_details_button.tr(),
          iconPath: SvgIcons.monitor,
          isCompleted: true,
          onViewPressed: () {
            context.push(UserAppRoutes.visitDetails);
          },
        ),
      ],
    );
  }
}
