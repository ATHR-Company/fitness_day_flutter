
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/vertical_day_tab_bar.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';
import 'package:fitness_day/core/widgets/activity_progress_card.dart';
import '../screens/hydration_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_today_tasks_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_today_tasks_state.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

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



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserTodayTasksCubit()..loadTasks(),
      child: const _UserTodayTasksPageContent(),
    );
  }
}

class _UserTodayTasksPageContent extends StatefulWidget {
  const _UserTodayTasksPageContent();

  @override
  State<_UserTodayTasksPageContent> createState() => _UserTodayTasksPageContentState();
}

class _UserTodayTasksPageContentState extends State<_UserTodayTasksPageContent> {
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
              child: BlocBuilder<UserTodayTasksCubit, UserTodayTasksState>(
                builder: (context, state) {
                  if (state is UserTodayTasksLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is UserTodayTasksLoaded) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    // التغذية
                    _SectionTitle(title: LocaleKeys.visit_details_nutrition.tr()),
                    SizedBox(height: 12.h),
                    TodayTasksSection(tasks: state.foodTasks.cast<TaskData>()),
                    SizedBox(height: 8.h),

                    // التمارين
                    _SectionTitle(title: LocaleKeys.visit_details_exercises.tr()),
                    SizedBox(height: 12.h),
                    TodayTasksSection(tasks: state.exerciseTasks.cast<TaskData>()),
                    SizedBox(height: 8.h),

                    // النشاط
                    _SectionTitle(title: LocaleKeys.visit_details_activity.tr()),
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
              );
            }
            return const SizedBox.shrink();
          },
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
