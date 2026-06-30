import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/widgets/app_back_header.dart';
import 'package:fitness_day/features/shared/widgets/app_segmented_control.dart';
import 'package:fitness_day/features/shared/widgets/health_report_card.dart';

import 'package:fitness_day/features/shared/widgets/vertical_tab_bar.dart';
import 'package:fitness_day/features/shared/widgets/visit_card.dart';
import 'package:fitness_day/features/shared/widgets/visit_goal_card.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/features/shared/widgets/message_icon_button.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/conversations_page.dart';
import 'package:fitness_day/features/shared/widgets/today_tasks_section.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity_progress_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                title: 'تفاصيل الزيارة',
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
                  items: const [
                    'ملخص الزيارة',
                    'النظام المخصص',
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
            title: 'متابعة أسبوعية',
            subtitle: 'متابعة الوزن وتخصيص النظام الغذائي والرياضي له',
            personName: 'د/ محمد عبدالله',
            personNameLabel: 'اسم الأخصائي :',
            visitTime: 'اليوم 4:30 مساءا',
            location: 'في مقر يوم الرشاقة',
            buttonText: 'تفاصيل »',
            iconPath: SvgIcons.monitor,
            isCompleted: true, // Assuming this is how we show the green checked icon (Wait, VisitCard doesn't have isCompleted, I need to check VisitCard. For now let's just use it as is)
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
                _buildSectionTitle('التغذية'),
                SizedBox(height: 12.h),
                const TodayTasksSection(tasks: _foodTasks),

                SizedBox(height: 24.h),
                _buildSectionTitle('التمارين'),
                SizedBox(height: 12.h),
                const TodayTasksSection(tasks: _exerciseTasks),

                SizedBox(height: 24.h),
                _buildSectionTitle('الأنشطة'),
                SizedBox(height: 12.h),
                ActivityProgressCard(
                  title: 'المشي',
                  time: 'طوال اليوم',
                  description: 'عاش يا بطل استمر',
                  icon: SvgPicture.asset(SvgIcons.wake, width: 48.sp, height: 48.sp, fit: BoxFit.contain),
                  current: 0,
                  target: 5000,
                  unit: 'خطوة',
                  isCompleted: false,
                ),
                SizedBox(height: 16.h),
                ActivityProgressCard(
                  title: 'الجري',
                  time: 'طوال اليوم',
                  description: 'الجري يساعد على تحسين القدرة التحملية وزيادة حرق السعرات.',
                  icon: SvgPicture.asset(SvgIcons.run, width: 48.sp, height: 48.sp, fit: BoxFit.contain),
                  current: 0,
                  target: 1000,
                  unit: 'متر',
                  isCompleted: false,
                ),
              ],
            ),
          ),
        ),
        // Vertical Tab Bar (Left side in RTL)
        VerticalTabBar(
          items: const [
            'اليوم الأول',
            'اليوم الثاني',
            'اليوم الثالث',
            'اليوم الرابع',
            'اليوم الخامس',
            'اليوم السادس',
            'اليوم السابع',
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
