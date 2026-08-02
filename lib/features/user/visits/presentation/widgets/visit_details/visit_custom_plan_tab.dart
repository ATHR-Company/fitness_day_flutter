import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/task_card.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';
import 'package:fitness_day/core/widgets/vertical_day_tab_bar.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/hydration_details_screen.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/steps_details_screen.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/assessment_details_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/shared/visits_section_title.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';

/// Second tab of the visit details page: the day's custom plan
/// (nutrition / exercises / activity) plus the vertical day selector.
class VisitCustomPlanTab extends StatelessWidget {
  final String assessmentId;
  final int selectedDayIndex;
  final ValueChanged<int> onDaySelected;

  const VisitCustomPlanTab({
    super.key,
    required this.assessmentId,
    required this.selectedDayIndex,
    required this.onDaySelected,
  });

  static String _fmt(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      return DateFormat('hh:mm a', 'en').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content
        Expanded(
          child: BlocBuilder<AssessmentDetailsCubit, AssessmentDetailsState>(
            builder: (context, state) {
              if (state is AssessmentDetailsLoading) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is AssessmentDetailsError) {
                return AppErrorView(
                  error: state.error,
                  message: state.message,
                  onRetry: () => context
                      .read<AssessmentDetailsCubit>()
                      .getDayDetails(assessmentId, selectedDayIndex + 1),
                );
              }
              if (state is AssessmentDetailsLoaded) {
                if (state.dayData == null) return const SizedBox.shrink();
                return _TasksFromData(
                  raw: state.dayData!,
                  assessmentId: assessmentId,
                  selectedDayIndex: selectedDayIndex,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),

        // Vertical day tabs
        VerticalDayTabBar(
          days: [
            LocaleKeys.visit_details_day_1.tr(),
            LocaleKeys.visit_details_day_2.tr(),
            LocaleKeys.visit_details_day_3.tr(),
            LocaleKeys.visit_details_day_4.tr(),
            LocaleKeys.visit_details_day_5.tr(),
            LocaleKeys.visit_details_day_6.tr(),
            LocaleKeys.visit_details_day_7.tr(),
          ],
          selectedIndex: selectedDayIndex,
          onDaySelected: onDaySelected,
        ),
      ],
    );
  }
}

/// Parses the raw day-plan payload into nutrition / exercise / activity
/// task lists and renders them as sections.
class _TasksFromData extends StatelessWidget {
  final Map<String, dynamic> raw;
  final String assessmentId;
  final int selectedDayIndex;

  const _TasksFromData({
    required this.raw,
    required this.assessmentId,
    required this.selectedDayIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Support both {data: {tasks:[]}} and {tasks:[]} shapes
    final inner = raw['data'] as Map<String, dynamic>? ?? raw;
    final tasks = inner['tasks'] as List? ?? [];
    final String apiAssessmentId = inner['assessmentId'] as String? ?? '';
    final resolvedAssessmentId = apiAssessmentId.isNotEmpty
        ? apiAssessmentId
        : (assessmentId.isNotEmpty
            ? assessmentId
            : (getIt<AppCache>().getAssessmentId() ?? ''));
    final dayNum = inner['dayNumber'] as int? ?? selectedDayIndex + 1;

    final List<TaskData> foodTasks = [];
    final List<TaskData> exerciseTasks = [];
    final List<TaskData> activityTasks = [];

    for (final task in tasks) {
      final String type = task['type'] ?? '';

      if (type == 'meal') {
        foodTasks.add(TaskData(
          imagePath: task['image'] ?? '',
          title: task['categoryName'] ?? '',
          description: task['name'] ?? '',
          time: VisitCustomPlanTab._fmt(task['time']),
          extraLabel: '${task['calories'] ?? 0}',
          extraUnit: LocaleKeys.home_home_calories_unit.tr(),
          extraIcon: Icons.local_fire_department,
          done: task['isCompleted'] ?? false,
          route: UserAppRoutes.mealDetails,
          routeExtra: {
            'mealId': task['mealId'] ?? '',
            'assessmentId': resolvedAssessmentId,
            'dayNumber': dayNum,
          },
        ));
      } else if (type == 'workout') {
        exerciseTasks.add(TaskData(
          imagePath: task['photo'] ?? '',
          title: task['name'] ?? '',
          description: task['description'] ?? '',
          time: VisitCustomPlanTab._fmt(task['time']),
          extraLabel: '${task['completedSets'] ?? 0}',
          extraUnit: '${task['totalSets'] ?? 0}',
          extraIcon: null,
          done: task['isCompleted'] ?? false,
          isExerciseDialog: true,
          workoutItemId: task['workoutItemId'] ?? '',
          workoutDayNumber: dayNum,
          workoutAssessmentId: resolvedAssessmentId,
        ));
      } else if (type == 'activity') {
        final String activityType = task['activityType'] ?? '';
        final double progress = (task['currentProgress'] as num?)?.toDouble() ?? 0;
        final double goal = (task['goal'] as num?)?.toDouble() ?? 0;
        final String unit = task['unit'] ?? '';
        final String activityId = task['activityId'] as String? ?? '';

        IconData icon;
        switch (activityType) {
          case 'hydration':
            icon = Icons.water_drop_outlined;
            break;
          case 'walking':
            icon = Icons.directions_walk;
            break;
          case 'running':
            icon = Icons.directions_run;
            break;
          default:
            icon = Icons.local_activity_outlined;
        }

        activityTasks.add(TaskData(
          imagePath: task['image'] ?? '',
          title: task['name'] ?? '',
          description: task['description'] ?? '',
          time: LocaleKeys.home_hydration_all_day.tr(),
          extraLabel: progress % 1 == 0
              ? progress.toInt().toString()
              : progress.toStringAsFixed(2),
          extraUnit: '/ $goal $unit',
          extraIcon: icon,
          done: task['isCompleted'] ?? false,
          onDetailsPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => activityType == 'hydration'
                    ? HydrationDetailsScreen(
                        assessmentId: resolvedAssessmentId,
                        dayNumber: dayNum,
                        activityId: activityId,
                      )
                    : StepsDetailsScreen(
                        type: activityType == 'running'
                            ? ActivityType.running
                            : ActivityType.walking,
                        assessmentId: resolvedAssessmentId,
                        dayNumber: dayNum,
                        activityId: activityId,
                      ),
              ),
            );
            // No refetch on the way back: those screens publish each
            // server-confirmed reading to AppEventBus, and
            // AssessmentDetailsCubit patches this day's payload from it — with
            // a silent refetch of its own only when the day holds two items
            // sharing one activityId and the patch would be ambiguous.
          },
        ));
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 0, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (foodTasks.isNotEmpty) ...[
            VisitsSectionTitle(title: LocaleKeys.visit_details_nutrition.tr()),
            SizedBox(height: 12.h),
            TodayTasksSection(tasks: foodTasks, plainBackground: true),
            SizedBox(height: 24.h),
          ],
          if (exerciseTasks.isNotEmpty) ...[
            VisitsSectionTitle(title: LocaleKeys.visit_details_exercises.tr()),
            SizedBox(height: 12.h),
            TodayTasksSection(tasks: exerciseTasks, plainBackground: true),
            SizedBox(height: 24.h),
          ],
          if (activityTasks.isNotEmpty) ...[
            VisitsSectionTitle(title: LocaleKeys.visit_details_activity.tr()),
            SizedBox(height: 12.h),
            ...activityTasks.map(
              (t) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: TaskCard(task: t, plainBackground: true),
              ),
            ),
          ],
          if (foodTasks.isEmpty && exerciseTasks.isEmpty && activityTasks.isEmpty)
            _NoTasksMessage(),
        ],
      ),
    );
  }
}

class _NoTasksMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40.h),
        child: Text(
          LocaleKeys.visits_no_tasks.tr(),
          style: TextStyleManager.style14Medium,
        ),
      ),
    );
  }
}
