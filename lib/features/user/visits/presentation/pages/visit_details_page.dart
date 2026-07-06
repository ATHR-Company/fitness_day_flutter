import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/health_report_card.dart';

import 'package:fitness_day/core/widgets/vertical_tab_bar.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/widgets/message_icon_button.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/conversations_page.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';


class VisitDetailsPage extends StatefulWidget {
  
  const VisitDetailsPage({super.key});

  @override
  State<VisitDetailsPage> createState() => _VisitDetailsPageState();
}

class _VisitDetailsPageState extends State<VisitDetailsPage> {
  int _selectedTabIndex = 0;
  int _selectedDayIndex = 0;



  static const List<TaskData> _foodTasks = [
    TaskData(
      imagePath: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=200',
      title: 'وجبة الافطار',
      description: 'شوفان بالحليب مع مكسرات وعسل',
      time: '8:00 صباحاً',
      extraLabel: '350',
      extraUnit: 'كالورى',
      extraIcon: Icons.local_fire_department,
      done: true,
      route: UserAppRoutes.mealDetails,
    ),
    TaskData(
      imagePath: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200',
      title: 'وجبة الغداء',
      description: '150 جم من صدور الدجاج المشوي + 6 ملاعق ارز+ سلطة خضراء',
      time: '3:00 ظهراً',
      extraLabel: '350',
      extraUnit: 'كالورى',
      extraIcon: Icons.local_fire_department,
      done: false,
      route: UserAppRoutes.mealDetails,
    ),
    TaskData(
      imagePath: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=200',
      title: 'وجبة العشاء',
      description: 'سمك مشوي + سلطة خضراء + عيش السمر',
      time: '3:00 مساءً',
      extraLabel: '350',
      extraUnit: 'كالورى',
      extraIcon: Icons.local_fire_department,
      done: false,
      route: UserAppRoutes.mealDetails,
    ),
  ];

  static const List<TaskData> _exerciseTasks = [
    TaskData(
      imagePath: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200',
      title: 'تمرين القرفصاء',
      description: 'تمرين البلانك يقوى عضلات البطن ويحسن الاستقرار العام للجسم',
      time: '3:00 ظهراً',
      extraLabel: '3',
      extraUnit: '3',
      extraIcon: null,
      done: true,
    ),
    TaskData(
      imagePath: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200',
      title: 'تمرين البلانك',
      description: 'تمرين البلانك يقوى عضلات البطن ويحسن الاستقرار العام للجسم',
      time: '3:00 ظهراً',
      extraLabel: '1',
      extraUnit: '3',
      extraIcon: null,
      done: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: AppBackHeader(
                title: LocaleKeys.visit_details_title.tr(),
                trailingWidget: MessageIconButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConversationsPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Segmented Control (2 tabs) - Only for previous visits
            
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppSegmentedControl(
                  type: AppSegmentedControlType.unified,
                  items: [
                    LocaleKeys.visit_details_tab_visit_data.tr(),
                    LocaleKeys.visit_details_tab_custom_plan.tr(),
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24.h),
                child: _selectedTabIndex == 0
                    ? _buildPreviousVisitSummaryTab()
                    : _buildCustomPlanTab(),
              ),
            ),
            ]
            // Content Area

        ),
      ),
    );
  }


  Widget _buildPreviousVisitSummaryTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Visit Card
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
            onViewPressed: () {},
            showButton: false,
          ),
          SizedBox(height: 16.h),

          // Visit Goal Card
          VisitGoalCard(
            title: 'ملخص الزيارة',
            goals: const [
              'تعديل السعرات اليومية لتناسب هدفك',
              'تحديث خطة التمارين',
              'ضبط توزيع البروتين والكربوهيدرات',
              'متابعة تقدمك خلال الأسبوع الماضي',
            ],
          ),
          SizedBox(height: 16.h),

          // Health Report Card
          const HealthReportCard(),
        ],
      ),
    );
  }

  Widget _buildCustomPlanTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content Area (Right side in RTL)
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 16.w, 0),
            child: Column(
              children: [
                _buildSectionTitle(LocaleKeys.visit_details_nutrition.tr()),
                SizedBox(height: 12.h),
                const TodayTasksSection(tasks: _foodTasks),

                SizedBox(height: 24.h),
                _buildSectionTitle(LocaleKeys.visit_details_exercises.tr()),
                SizedBox(height: 12.h),
                const TodayTasksSection(tasks: _exerciseTasks),

                SizedBox(height: 24.h),
                _buildSectionTitle(LocaleKeys.visit_details_activity.tr()),
                SizedBox(height: 12.h),
                TaskCard(
                  task: const TaskData(
                    title: 'المشي',
                    time: 'طوال اليوم',
                    description: 'عاش يا بطل استمر',
                    imagePath: SvgIcons.wake,
                    isSvgImage: true,
                    extraLabel: '0',
                    extraUnit: '5000 خطوة',
                    extraIcon: null,
                    done: false,
                  ),
                ),
                SizedBox(height: 16.h),
                TaskCard(
                  task: const TaskData(
                    title: 'الجري',
                    time: 'طوال اليوم',
                    description: 'الجري يساعد على تحسين القدرة التحملية وزيادة حرق السعرات.',
                    imagePath: SvgIcons.run,
                    isSvgImage: true,
                    extraLabel: '0',
                    extraUnit: '1000 متر',
                    extraIcon: null,
                    done: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Vertical Tab Bar (Left side in RTL)
        VerticalTabBar(
          items: [
            LocaleKeys.visit_details_day_1.tr(),
            LocaleKeys.visit_details_day_2.tr(),
            LocaleKeys.visit_details_day_3.tr(),
            LocaleKeys.visit_details_day_4.tr(),
            LocaleKeys.visit_details_day_5.tr(),
            LocaleKeys.visit_details_day_6.tr(),
            LocaleKeys.visit_details_day_7.tr(),
          ],
          selectedIndex: _selectedDayIndex,
          onItemSelected: (index) {
            setState(() {
              _selectedDayIndex = index;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyleManager.heading2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

}
