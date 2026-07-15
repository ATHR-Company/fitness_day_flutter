import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/health_report_card.dart';
import 'package:fitness_day/core/widgets/message_icon_button.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/core/widgets/task_card.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';
import 'package:fitness_day/core/widgets/vertical_tab_bar.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/conversations_page.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/assessment_details_cubit.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class VisitDetailsPage extends StatelessWidget {
  final String assessmentId;
  final int dayNumber;

  const VisitDetailsPage({
    super.key,
    required this.assessmentId,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AssessmentDetailsCubit>()
        ..getInitialData(assessmentId, dayNumber),
      child: _VisitDetailsContent(
        assessmentId: assessmentId,
        initialDayNumber: dayNumber,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _VisitDetailsContent extends StatefulWidget {
  final String assessmentId;
  final int initialDayNumber;

  const _VisitDetailsContent({
    required this.assessmentId,
    required this.initialDayNumber,
  });

  @override
  State<_VisitDetailsContent> createState() => _VisitDetailsContentState();
}

class _VisitDetailsContentState extends State<_VisitDetailsContent> {
  int _selectedTabIndex = 0;
  int _selectedDayIndex = 0;

  void _onDaySelected(int index) {
    setState(() => _selectedDayIndex = index);
    context.read<AssessmentDetailsCubit>()
      .getDayDetails(widget.assessmentId, index + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10.h),

            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: AppBackHeader(
                title: LocaleKeys.visit_details_title.tr(),
                trailingWidget: MessageIconButton(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ConversationsPage()),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // ── Segmented control ───────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: AppSegmentedControl(
                type: AppSegmentedControlType.unified,
                items: [
                  LocaleKeys.visit_details_tab_visit_data.tr(),
                  LocaleKeys.visit_details_tab_custom_plan.tr(),
                ],
                selectedIndex: _selectedTabIndex,
                onItemSelected: (i) => setState(() => _selectedTabIndex = i),
              ),
            ),
            SizedBox(height: 24.h),

            // ── Content ─────────────────────────────────────────────
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildVisitSummaryTab()
                  : _buildCustomPlanTab(),
            ),
          ],
        ),
      ),
    ));
  }

  // ── Tab 0: ملخص الزيارة ──────────────────────────────────────────────────

  Widget _buildVisitSummaryTab() {
    return BlocBuilder<AssessmentDetailsCubit, AssessmentDetailsState>(
      builder: (context, state) {
        if (state is AssessmentDetailsLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state is AssessmentDetailsLoaded) {
          final summary = state.summaryData?['data'] ?? state.summaryData;
          if (summary == null) return const SizedBox.shrink();

          final specialistName = summary['specialistName'] ?? LocaleKeys.spec_mock_name.tr();
          final visitTime = summary['appointment'] != null
              ? _fmtDate(summary['appointment'])
              : '${LocaleKeys.visits_today.tr()} 4:30 ${LocaleKeys.visits_pm.tr()}';
          final location = summary['placement'] ?? LocaleKeys.visits_hq_location.tr();
          
          final String goalStr = summary['goal'] ?? '';
          List<String> goals = [];
          if (goalStr.isNotEmpty) {
            goals = goalStr.split('•').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          }

          final healthReport = summary['healthReport'] as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 24.h),
            child: Column(
              children: [
                VisitCard(
                  timeRemaining: '',
                  title: summary['name'] ?? LocaleKeys.home_weekly_follow_up.tr(),
                  subtitle: summary['description'] ?? LocaleKeys.home_weekly_follow_up_desc.tr(),
                  personName: specialistName,
                  personNameLabel: LocaleKeys.visits_client_name_label.tr(),
                  visitTime: visitTime,
                  location: location,
                  buttonText: LocaleKeys.home_details_button.tr(),
                  iconPath: SvgIcons.monitor,
                  isCompleted: true,
                  onViewPressed: () {},
                  showButton: false,
                ),
                SizedBox(height: 16.h),
                if (goals.isNotEmpty) ...[
                  VisitGoalCard(
                    title: 'ملخص الزيارة',
                    goals: goals,
                  ),
                  SizedBox(height: 16.h),
                ],
                HealthReportCard(healthReport: healthReport),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final date = DateTime.parse(iso).toLocal();
      return DateFormat('yyyy-MM-dd hh:mm a', 'en').format(date);
    } catch (_) {
      return '';
    }
  }

  // ── Tab 1: النظام المخصص — live from API ────────────────────────────────

  Widget _buildCustomPlanTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content
        Expanded(
          child: BlocBuilder<AssessmentDetailsCubit, AssessmentDetailsState>(
            builder: (context, state) {
              if (state is AssessmentDetailsLoading) {
                return Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is AssessmentDetailsError) {
                return Center(child: Text(state.message));
              }
              if (state is AssessmentDetailsLoaded) {
                if (state.dayData == null) return const SizedBox.shrink();
                return _buildTasksFromData(state.dayData!);
              }
              return const SizedBox.shrink();
            },
          ),
        ),

        // Vertical day tabs
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
          onItemSelected: _onDaySelected,
        ),
      ],
    );
  }

  Widget _buildTasksFromData(Map<String, dynamic> raw) {
    // Support both {data: {tasks:[]}} and {tasks:[]} shapes
    final inner = raw['data'] as Map<String, dynamic>? ?? raw;
    final tasks = inner['tasks'] as List? ?? [];
    final assessmentId =
        inner['assessmentId'] as String? ?? widget.assessmentId;
    final dayNum =
        inner['dayNumber'] as int? ?? _selectedDayIndex + 1;

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
          time: _fmt(task['time']),
          extraLabel: '${task['calories'] ?? 0}',
          extraUnit: LocaleKeys.home_home_calories_unit.tr(),
          extraIcon: Icons.local_fire_department,
          done: task['isCompleted'] ?? false,
          route: UserAppRoutes.mealDetails,
          routeExtra: {
            'mealId': task['mealId'] ?? '',
            'assessmentId': assessmentId,
            'dayNumber': dayNum,
          },
        ));
      } else if (type == 'workout') {
        exerciseTasks.add(TaskData(
          imagePath: task['photo'] ?? '',
          title: task['name'] ?? '',
          description: task['description'] ?? '',
          time: _fmt(task['time']),
          extraLabel: '${task['completedSets'] ?? 0}',
          extraUnit: '${task['totalSets'] ?? 0}',
          extraIcon: null,
          done: task['isCompleted'] ?? false,
          isExerciseDialog: true,
          workoutItemId: task['workoutItemId'] ?? '',
          workoutDayNumber: dayNum,
        ));
      } else if (type == 'activity') {
        final String activityType = task['activityType'] ?? '';
        final double progress =
            (task['currentProgress'] as num?)?.toDouble() ?? 0;
        final double goal = (task['goal'] as num?)?.toDouble() ?? 0;
        final String unit = task['unit'] ?? '';

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
          routeExtra: {
            'activityId': task['activityId'] ?? '',
            'activityType': activityType,
            'assessmentId': assessmentId,
            'dayNumber': dayNum,
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
            _sectionTitle(LocaleKeys.visit_details_nutrition.tr()),
            SizedBox(height: 12.h),
            TodayTasksSection(tasks: foodTasks, plainBackground: true),
            SizedBox(height: 24.h),
          ],
          if (exerciseTasks.isNotEmpty) ...[
            _sectionTitle(LocaleKeys.visit_details_exercises.tr()),
            SizedBox(height: 12.h),
            TodayTasksSection(tasks: exerciseTasks, plainBackground: true),
            SizedBox(height: 24.h),
          ],
          if (activityTasks.isNotEmpty) ...[
            _sectionTitle(LocaleKeys.visit_details_activity.tr()),
            SizedBox(height: 12.h),
            ...activityTasks.map(
              (t) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: TaskCard(task: t, plainBackground: true),
              ),
            ),
          ],
          if (foodTasks.isEmpty &&
              exerciseTasks.isEmpty &&
              activityTasks.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40.h),
                child: Text(
                  'لا توجد مهام لهذا اليوم',
                  style: TextStyleManager.style14Medium,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          style: TextStyleManager.heading2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  String _fmt(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      return DateFormat('hh:mm a', 'en').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return '';
    }
  }
}
