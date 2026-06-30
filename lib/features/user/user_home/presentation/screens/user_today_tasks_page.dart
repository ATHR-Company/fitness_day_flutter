import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/vertical_day_tab_bar.dart';
import '../../../../shared/widgets/today_tasks_section.dart';
import '../widgets/activity_progress_card.dart';
import '../screens/hydration_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserTodayTasksPage extends StatefulWidget {
  const UserTodayTasksPage({super.key});

  @override
  State<UserTodayTasksPage> createState() => _UserTodayTasksPageState();
}

class _UserTodayTasksPageState extends State<UserTodayTasksPage> {
  int _selectedDayIndex = 0;

  List<String> get _days => [
        'visit_details.day_1'.tr(),
        'visit_details.day_2'.tr(),
        'visit_details.day_3'.tr(),
        'visit_details.day_4'.tr(),
        'visit_details.day_5'.tr(),
        'visit_details.day_6'.tr(),
        'visit_details.day_7'.tr(),
      ];

  // ── Food tasks ─────────────────────────────────────────────────────────────
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
    ),
  ];

  // ── Exercise tasks ──────────────────────────────────────────────────────────
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
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'home.todays_tasks'.tr(),
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Content (right side in RTL) ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // التغذية
                    _SectionTitle(title: 'التغذية'),
                    SizedBox(height: 12.h),
                    TodayTasksSection(tasks: _foodTasks),
                    SizedBox(height: 8.h),

                    // التمارين
                    _SectionTitle(title: 'التمارين'),
                    SizedBox(height: 12.h),
                    TodayTasksSection(tasks: _exerciseTasks),
                    SizedBox(height: 8.h),

                    // النشاط
                    _SectionTitle(title: 'النشاط'),
                    SizedBox(height: 12.h),
                    ActivityProgressCard(
                      title: 'home.hydration_title'.tr(),
                      time: 'home.hydration_all_day'.tr(),
                      description: 'home.hydration_desc'.tr(),
                      icon: SvgPicture.asset(SvgIcons.waterBorder, fit: BoxFit.contain),
                      current: 2.50,
                      target: 2.50,
                      unit: 'home.water_unit'.tr(),
                      isCompleted: true,
                      onDetailsPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HydrationDetailsScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    ActivityProgressCard(
                      title: 'المشي',
                      time: 'طوال اليوم',
                      description: 'عاش يا بطل استمر',
                      icon: SvgPicture.asset(SvgIcons.wake,  fit: BoxFit.contain),
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
                      icon: SvgPicture.asset(SvgIcons.run,  fit: BoxFit.contain),
                      current: 0,
                      target: 1000,
                      unit: 'متر',
                      isCompleted: false,
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // ── Vertical day tab bar (left side in RTL) ───────────────────────
            VerticalDayTabBar(
              days: _days,
              selectedIndex: _selectedDayIndex,
              onDaySelected: (index) => setState(() => _selectedDayIndex = index),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: TextStyleManager.heading2.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
