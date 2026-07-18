import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/features/user/visits/data/models/assessment_model.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/assessments_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/change_visit_dialog.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/visit_log/week_navigation_header.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/visit_log/week_calendar_strip.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/visit_log/visit_log_card.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';

class VisitLogPage extends StatefulWidget {
  const VisitLogPage({super.key});

  @override
  State<VisitLogPage> createState() => _VisitLogPageState();
}

class _VisitLogPageState extends State<VisitLogPage> {
  // Index into the _appointmentDays list (built per-load)
  int _selectedDayIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: const UserAppDrawer(),
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: LocaleKeys.drawer_visits_log.tr(),
                onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
              Expanded(
                child: BlocBuilder<AssessmentsCubit, AssessmentsState>(
                  builder: (context, state) {
                    if (state is AssessmentsLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    if (state is AssessmentsError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is AssessmentsLoaded) {
                      return _buildLoaded(context, state);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, AssessmentsLoaded state) {
    final currentWeekStart = state.currentWeekStart;

    // Build the full 7-day week
    final List<DateTime> weekDays = List.generate(
      7,
      (i) => DateTime(
        currentWeekStart.year,
        currentWeekStart.month,
        currentWeekStart.day + i,
      ),
    );

    // Collect appointment dates (date-only)
    final Set<String> appointmentDateKeys = state.response.assessments
        .map((a) => WeekCalendarStrip.dateKey(a.appointment))
        .toSet();

    // Clamp selected index to a day that has appointments
    final List<int> validIndices = [
      for (int i = 0; i < weekDays.length; i++)
        if (appointmentDateKeys.contains(WeekCalendarStrip.dateKey(weekDays[i]))) i,
    ];

    if (validIndices.isNotEmpty && !validIndices.contains(_selectedDayIndex)) {
      // Auto-select first appointment day on week change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedDayIndex = validIndices.first);
      });
    }

    // Filter assessments for selected day
    final selectedDate = weekDays.length > _selectedDayIndex
        ? weekDays[_selectedDayIndex]
        : null;

    List<AssessmentModel> visibleAssessments = [];
    if (selectedDate != null) {
      visibleAssessments = state.response.assessments
          .where((a) =>
              WeekCalendarStrip.dateKey(a.appointment) ==
              WeekCalendarStrip.dateKey(selectedDate))
          .toList();
    }

    final assessmentsCubit = context.read<AssessmentsCubit>();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Week navigation header ─────────────────────────────────
          WeekNavigationHeader(
            weekStart: currentWeekStart,
            weekEnd: currentWeekStart.add(const Duration(days: 6)),
            onPrevious: () {
              setState(() => _selectedDayIndex = 0);
              assessmentsCubit.previousWeek();
            },
            onNext: () {
              setState(() => _selectedDayIndex = 0);
              assessmentsCubit.nextWeek();
            },
            isPreviousEnabled: assessmentsCubit.canGoPrevious,
            isNextEnabled: assessmentsCubit.canGoNext,
          ),
          SizedBox(height: 16.h),

          // ── 7-day calendar strip ───────────────────────────────────
          WeekCalendarStrip(
            weekDays: weekDays,
            appointmentDateKeys: appointmentDateKeys,
            selectedIndex: _selectedDayIndex,
            onDaySelected: (i) {
              if (appointmentDateKeys.contains(WeekCalendarStrip.dateKey(weekDays[i]))) {
                setState(() => _selectedDayIndex = i);
              }
            },
          ),

          SizedBox(height: 24.h),

          // ── Visit cards for the selected day ──────────────────────
          if (validIndices.isEmpty)
            _EmptyVisitsMessage(text: LocaleKeys.visits_no_visits_this_week.tr())
          else if (visibleAssessments.isEmpty)
            _EmptyVisitsMessage(text: LocaleKeys.visits_no_visits_today.tr())
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleAssessments.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final assessment = visibleAssessments[index];
                return VisitLogCard(
                  assessment: assessment,
                  onDetailsPressed: assessment.canShowDetails
                      ? () => context.push(
                            UserAppRoutes.visitDetails,
                            extra: {
                              'assessmentId': assessment.assessmentId,
                              'dayNumber': 1,
                            },
                          )
                      : null,
                  onReschedulePressed: () =>
                      showChangeVisitDialog(context, assessment.assessmentId),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Centered placeholder shown when there are no visits for the
/// selected week or day.
class _EmptyVisitsMessage extends StatelessWidget {
  final String text;

  const _EmptyVisitsMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Text(
          text,
          style: TextStyleManager.style14Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
