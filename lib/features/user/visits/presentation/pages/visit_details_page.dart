import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/message_icon_button.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/conversations_page.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/assessment_details_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/visit_details/visit_summary_tab.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/visit_details/visit_custom_plan_tab.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                    ? const VisitSummaryTab()
                    : VisitCustomPlanTab(
                        assessmentId: widget.assessmentId,
                        selectedDayIndex: _selectedDayIndex,
                        onDaySelected: _onDaySelected,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
