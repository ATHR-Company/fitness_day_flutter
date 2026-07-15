import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/features/user/visits/data/models/assessment_model.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/assessments_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/change_visit_dialog.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
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
    final response = state.response;
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
    final Set<String> appointmentDateKeys = response.assessments
        .map((a) => _dateKey(a.appointment))
        .toSet();

    // Clamp selected index to a day that has appointments
    final List<int> validIndices = [
      for (int i = 0; i < weekDays.length; i++)
        if (appointmentDateKeys.contains(_dateKey(weekDays[i]))) i,
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
      visibleAssessments = response.assessments
          .where((a) => _dateKey(a.appointment) == _dateKey(selectedDate))
          .toList();
    }

    final assessmentsCubit = context.read<AssessmentsCubit>();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Week navigation header ─────────────────────────────────
          _WeekNavigationHeader(
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
          _WeekCalendarStrip(
            weekDays: weekDays,
            appointmentDateKeys: appointmentDateKeys,
            selectedIndex: _selectedDayIndex,
            onDaySelected: (i) {
              if (appointmentDateKeys.contains(_dateKey(weekDays[i]))) {
                setState(() => _selectedDayIndex = i);
              }
            },
          ),

          SizedBox(height: 24.h),

          // ── Visit cards for the selected day ──────────────────────
          if (validIndices.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 48.sp,
                      color: AppColors.divider,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'visits.no_visits_this_week'.tr(),
                      style: TextStyleManager.style14Medium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (visibleAssessments.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Text(
                  'visits.no_visits_today'.tr(),
                  style: TextStyleManager.style14Medium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleAssessments.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final assessment = visibleAssessments[index];
                return _VisitCard(
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

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

// ── Week navigation header ───────────────────────────────────────────────────

class _WeekNavigationHeader extends StatelessWidget {
  final DateTime weekStart;
  final DateTime weekEnd;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isPreviousEnabled;
  final bool isNextEnabled;

  const _WeekNavigationHeader({
    required this.weekStart,
    required this.weekEnd,
    required this.onPrevious,
    required this.onNext,
    required this.isPreviousEnabled,
    required this.isNextEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMM', context.locale.languageCode);
    final yearFormatter = DateFormat('yyyy', 'en');
    final label =
        '${formatter.format(weekStart)} – ${formatter.format(weekEnd)}  ${yearFormatter.format(weekStart)}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundTint,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous week
          _CalNavArrow(
            icon: Icons.chevron_left,
            onTap: onPrevious,
            enabled: isPreviousEnabled,
          ),
          Flexible(
            child: Text(
              label,
              style: TextStyleManager.style12Regular.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Next week
          _CalNavArrow(
            icon: Icons.chevron_right,
            onTap: onNext,
            enabled: isNextEnabled,
          ),
        ],
      ),
    );
  }
}

class _CalNavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _CalNavArrow({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: enabled ? AppColors.white : AppColors.divider.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, size: 22.sp, color: enabled ? AppColors.primary : AppColors.divider),
      ),
    );
  }
}

// ── 7-day calendar strip ─────────────────────────────────────────────────────

class _WeekCalendarStrip extends StatelessWidget {
  final List<DateTime> weekDays;
  final Set<String> appointmentDateKeys;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const _WeekCalendarStrip({
    required this.weekDays,
    required this.appointmentDateKeys,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(weekDays.length, (i) {
        final day = weekDays[i];
        final hasAppointment = appointmentDateKeys.contains(_dateKey(day));
        final isSelected = i == selectedIndex && hasAppointment;
        final dayName =
            DateFormat.E(context.locale.languageCode).format(day);
        final dayNum = DateFormat.d('en').format(day);

        return Expanded(
          child: GestureDetector(
            onTap: hasAppointment ? () => onDaySelected(i) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : hasAppointment
                        ? AppColors.backgroundTint
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(14.r),
                border: hasAppointment && !isSelected
                    ? Border.all(
                        color: AppColors.greenMint,
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Day name
                  Text(
                    dayName,
                    style: TextStyleManager.style9Medium.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : hasAppointment
                              ? AppColors.textPrimary
                              : AppColors.divider,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Date number
                  Text(
                    dayNum,
                    style: TextStyleManager.style14Bold.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : hasAppointment
                              ? AppColors.black
                              : AppColors.divider,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Appointment dot indicator
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: hasAppointment && !isSelected ? 1.0 : 0.0,
                    child: Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
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
}

// ── Internal visit card ──────────────────────────────────────────────────────

class _VisitCard extends StatelessWidget {
  final AssessmentModel assessment;
  final VoidCallback? onDetailsPressed;
  final VoidCallback onReschedulePressed;

  const _VisitCard({
    required this.assessment,
    required this.onDetailsPressed,
    required this.onReschedulePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(4.r),
          topEnd: Radius.circular(4.r),
          bottomEnd: Radius.circular(4.r),
          bottomStart: Radius.circular(32.r),
        ),
        border: Border.all(color: AppColors.greenMint, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppImage(
                  assessment.image.isNotEmpty
                      ? assessment.image
                      : SvgIcons.monitor,
                  width: 44.w,
                  height: 44.w,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assessment.name,
                        style: TextStyleManager.heading3.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        assessment.description,
                        style: TextStyleManager.style9Medium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

          
            SizedBox(height: 12.h),

            // ── Details ───────────────────────────────────────────────
            _row(LocaleKeys.visits_client_name_label.tr(), assessment.specialistName),
            SizedBox(height: 6.h),
            _row(
              LocaleKeys.visits_visit_time_label.tr(),
              DateFormat('yyyy-MM-dd hh:mm a', context.locale.languageCode)
                  .format(assessment.appointment),
            ),
            SizedBox(height: 6.h),
            _row(LocaleKeys.visits_visit_location_label.tr(), assessment.placement),
            SizedBox(height: 18.h),

            // ── Action buttons ────────────────────────────────────────
            if (assessment.canChangePlaceOrTime || onDetailsPressed != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Reschedule button
                  if (assessment.canChangePlaceOrTime)
                    OutlinedButton(
                      onPressed: onReschedulePressed,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(100.w, 38.h),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      child: Text(
                        LocaleKeys.visit_details_reschedule.tr(),
                        style: TextStyleManager.style12Regular.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  if (assessment.canChangePlaceOrTime && onDetailsPressed != null)
                    SizedBox(width: 10.w),

                  // Details button
                  if (onDetailsPressed != null)
                    ElevatedButton(
                      onPressed: onDetailsPressed,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(100.w, 38.h),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LocaleKeys.home_details_button.tr(),
                            style: TextStyleManager.style12Regular.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Directionality.of(context) == ui.TextDirection.rtl
                                ? Icons.keyboard_double_arrow_left_rounded
                                : Icons.keyboard_double_arrow_right_rounded,
                            size: 16.sp,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyleManager.style9Medium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              value,
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
}
