import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/core/widgets/task_card.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';
import 'package:fitness_day/core/widgets/vertical_day_tab_bar.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_today_tasks_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_today_tasks_state.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/hydration_details_screen.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/steps_details_screen.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/today_tasks/task_section_title.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';

class UserTodayTasksContent extends StatefulWidget {
  const UserTodayTasksContent({super.key});

  @override
  State<UserTodayTasksContent> createState() => _UserTodayTasksContentState();
}

class _UserTodayTasksContentState extends State<UserTodayTasksContent> {
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
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
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
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Content ────────────────────────────────────────────────
                    Expanded(
                      child: BlocBuilder<UserTodayTasksCubit, UserTodayTasksState>(
                        builder: (context, state) {
                          if (state is UserTodayTasksLoading) {
                            return Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            );
                          }

                          if (state is UserTodayTasksError) {
                            return AppErrorView(
                              error: state.error,
                              message: state.message,
                              onRetry: () => context
                                  .read<UserTodayTasksCubit>()
                                  .loadTasks(dayNumber: _selectedDayIndex + 1),
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
                                    TaskSectionTitle(
                                        title: LocaleKeys.visit_details_nutrition
                                            .tr()),
                                    SizedBox(height: 12.h),
                                    TodayTasksSection(
                                        tasks: state.foodTasks,
                                        plainBackground: true),
                                    SizedBox(height: 8.h),
                                  ],
                                  if (state.exerciseTasks.isNotEmpty) ...[
                                    TaskSectionTitle(
                                        title: LocaleKeys.visit_details_exercises
                                            .tr()),
                                    SizedBox(height: 12.h),
                                    TodayTasksSection(
                                        tasks: state.exerciseTasks,
                                        plainBackground: true),
                                    SizedBox(height: 8.h),
                                  ],
                                  if (state.activityTasks.isNotEmpty) ...[
                                    TaskSectionTitle(
                                        title: LocaleKeys.visit_details_activity
                                            .tr()),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback? _buildActivityCallback(
      BuildContext context, TaskData task) {
    // Extract IDs stored in routeExtra by UserTodayTasksCubit
    final extra = task.routeExtra as Map<String, dynamic>?;
    final String assessmentId = extra?['assessmentId'] as String? ?? '';
    final int dayNumber = extra?['dayNumber'] as int? ?? 1;
    final String activityId = extra?['activityId'] as String? ?? '';
    // Dispatch on the server's activityType, not the localized title — a
    // renamed activity ("مشي سريع") must still open its screen.
    final String activityType = extra?['activityType'] as String? ?? '';

    if (activityType == 'hydration') {
      return () => _openActivity(
            context,
            HydrationDetailsScreen(
              assessmentId: assessmentId,
              dayNumber: dayNumber,
              activityId: activityId,
            ),
          );
    }
    if (activityType == 'walking' || activityType == 'running') {
      return () => _openActivity(
            context,
            StepsDetailsScreen(
              type: activityType == 'running'
                  ? ActivityType.running
                  : ActivityType.walking,
              assessmentId: assessmentId,
              dayNumber: dayNumber,
              activityId: activityId,
            ),
          );
    }
    return null;
  }

  /// Opens an activity screen. No reload on the way back — the activity screens
  /// publish each server-confirmed reading to `AppEventBus` as it lands, and
  /// [UserTodayTasksCubit] patches the one card it belongs to. Refetching the
  /// whole day here would repeat a request whose answer already arrived.
  void _openActivity(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
