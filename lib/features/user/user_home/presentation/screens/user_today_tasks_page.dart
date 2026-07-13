import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/vertical_day_tab_bar.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';
import 'package:fitness_day/core/widgets/task_card.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import '../screens/hydration_details_screen.dart';
import '../screens/steps_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_today_tasks_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_today_tasks_state.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

class UserTodayTasksPage extends StatelessWidget {
  const UserTodayTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserTodayTasksCubit()..loadTasks(dayNumber: 1),
      child: const _UserTodayTasksPageContent(),
    );
  }
}

class _UserTodayTasksPageContent extends StatefulWidget {
  const _UserTodayTasksPageContent();

  @override
  State<_UserTodayTasksPageContent> createState() =>
      _UserTodayTasksPageContentState();
}

class _UserTodayTasksPageContentState
    extends State<_UserTodayTasksPageContent> {
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

  void _onDaySelected(int index) {
    setState(() => _selectedDayIndex = index);
    context.read<UserTodayTasksCubit>().loadTasks(dayNumber: index + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Content ────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<UserTodayTasksCubit, UserTodayTasksState>(
              builder: (context, state) {
                if (state is UserTodayTasksLoading) {
                  return Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is UserTodayTasksError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: AppColors.primary, size: 48.sp),
                        SizedBox(height: 12.h),
                        Text(state.message,
                            style: TextStyleManager.style11Medium,
                            textAlign: TextAlign.center),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => context
                              .read<UserTodayTasksCubit>()
                              .loadTasks(
                                  dayNumber: _selectedDayIndex + 1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is UserTodayTasksLoaded) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.foodTasks.isNotEmpty) ...[
                          _SectionTitle(
                              title: LocaleKeys.visit_details_nutrition
                                  .tr()),
                          SizedBox(height: 12.h),
                          TodayTasksSection(
                              tasks: state.foodTasks,
                              plainBackground: true),
                          SizedBox(height: 8.h),
                        ],
                        if (state.exerciseTasks.isNotEmpty) ...[
                          _SectionTitle(
                              title: LocaleKeys.visit_details_exercises
                                  .tr()),
                          SizedBox(height: 12.h),
                          TodayTasksSection(
                              tasks: state.exerciseTasks,
                              plainBackground: true),
                          SizedBox(height: 8.h),
                        ],
                        if (state.activityTasks.isNotEmpty) ...[
                          _SectionTitle(
                              title:
                                  LocaleKeys.visit_details_activity.tr()),
                          SizedBox(height: 12.h),
                          ...state.activityTasks.map(
                            (task) => Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: TaskCard(
                                plainBackground: true,
                                task: task.copyWith(
                                  onDetailsPressed: _buildActivityCallback(
                                      context, task),
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 24.h),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // ── Vertical day tab bar ────────────────────────────────────
          VerticalDayTabBar(
            days: _days,
            selectedIndex: _selectedDayIndex,
            onDaySelected: _onDaySelected,
          ),
        ],
      ),
    );
  }

  VoidCallback? _buildActivityCallback(
      BuildContext context, TaskData task) {
    final String titleLower = task.title.toLowerCase();
    // Extract IDs stored in routeExtra by UserTodayTasksCubit
    final extra = task.routeExtra as Map<String, dynamic>?;
    final String assessmentId = extra?['assessmentId'] as String? ?? '';
    final int dayNumber = extra?['dayNumber'] as int? ?? 1;
    final String activityId = extra?['activityId'] as String? ?? '';

    if (titleLower.contains('ترطيب') || titleLower.contains('hydration')) {
      return () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HydrationDetailsScreen(
                assessmentId: assessmentId,
                dayNumber: dayNumber,
                activityId: activityId,
              ),
            ),
          );
    }
    if (titleLower.contains('مشي') || titleLower.contains('walking')) {
      return () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StepsDetailsScreen(
                type: ActivityType.walking,
                assessmentId: assessmentId,
                dayNumber: dayNumber,
                activityId: activityId,
              ),
            ),
          );
    }
    if (titleLower.contains('جري') || titleLower.contains('running')) {
      return () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StepsDetailsScreen(
                type: ActivityType.running,
                assessmentId: assessmentId,
                dayNumber: dayNumber,
                activityId: activityId,
              ),
            ),
          );
    }
    return null;
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
