import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/health_report_card.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/assessment_details_cubit.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// First tab of the visit details page: a summary card, visit goals,
/// and the health report, built from [AssessmentDetailsCubit] state.
class VisitSummaryTab extends StatelessWidget {
  const VisitSummaryTab({super.key});

  static String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final date = DateTime.parse(iso).toLocal();
      return DateFormat('yyyy-MM-dd hh:mm a', 'en').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
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

          final specialistName =
              summary['specialistName'] ?? LocaleKeys.spec_mock_name.tr();
          final visitTime = summary['appointment'] != null
              ? _fmtDate(summary['appointment'])
              : '${LocaleKeys.visits_today.tr()} 4:30 ${LocaleKeys.visits_pm.tr()}';
          final location = summary['placement'] ?? LocaleKeys.visits_hq_location.tr();

          final String goalStr = summary['goal'] ?? '';
          List<String> goals = [];
          if (goalStr.isNotEmpty) {
            goals = goalStr
                .split('•')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }

          final healthReport = summary['healthReport'] as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 24.h),
            child: Column(
              children: [
                VisitCard(
                  timeRemaining: '',
                  title: summary['name'] ?? LocaleKeys.home_weekly_follow_up.tr(),
                  subtitle:
                      summary['description'] ?? LocaleKeys.home_weekly_follow_up_desc.tr(),
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
                    title: LocaleKeys.visit_details_visit_summary_title.tr(),
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
}
