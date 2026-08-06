import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/utils/date_time_utils.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:fitness_day/core/widgets/message_icon_button.dart';
import 'package:fitness_day/core/widgets/upcoming_visit_show_screen.dart';
import 'package:fitness_day/core/widgets/reschedule_visit_dialog.dart';
import 'package:fitness_day/features/user/support/presentation/pages/contact_us_page.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/assessment_details_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/change_assessment_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/change_location_dialog.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

/// The user's view of a visit that hasn't started yet.
///
/// Every value on this screen used to be a placeholder — a made-up specialist,
/// "4:30 PM", a clinic in Mansoura and four sample goals — none of which had
/// anything to do with the visit being opened. It all comes from
/// `GET /user-assessments/:id/details` now.
class UserUpcomingVisitPage extends StatelessWidget {
  final String assessmentId;
  final int dayNumber;

  const UserUpcomingVisitPage({
    super.key,
    required this.assessmentId,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AssessmentDetailsCubit>()..getSummary(assessmentId),
      child: BlocBuilder<AssessmentDetailsCubit, AssessmentDetailsState>(
        builder: (context, state) {
          if (state is AssessmentDetailsError) {
            return Scaffold(
              body: AppErrorView(
                error: state.error,
                message: state.message,
                onRetry: () =>
                    context.read<AssessmentDetailsCubit>().getSummary(assessmentId),
              ),
            );
          }

          if (state is! AssessmentDetailsLoaded) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          // The endpoint wraps its payload in `data` on some routes and not on
          // others — same handling as the summary tab.
          final summary = (state.summaryData?['data'] ?? state.summaryData)
              as Map<String, dynamic>?;

          return _buildScreen(context, summary ?? const {});
        },
      ),
    );
  }

  Widget _buildScreen(BuildContext context, Map<String, dynamic> summary) {
    final appointment = _string(summary['appointment']);

    return UpcomingVisitShowScreen(
      title: LocaleKeys.visits_upcoming_visit_title.tr(),
      trailingWidget: MessageIconButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactUsPage()),
          );
        },
      ),
      visitTimeRemaining:
          appointment.isEmpty ? '' : formatVisitTimeRemaining(appointment, context),
      visitTitle: _string(summary['name']),
      visitSubtitle: _string(summary['description']),
      personName: _specialistName(summary),
      personNameLabel: LocaleKeys.visits_specialist_name_label.tr(),
      visitTime:
          appointment.isEmpty ? '' : formatVisitDate(appointment, context),
      visitLocation: _string(summary['placement']),
      visitGoalTitle: LocaleKeys.visit_details_visit_goal_title.tr(),
      visitGoals: _goals(summary['goal']),
      bottomAction: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: LocaleKeys.visits_change_location_button.tr(),
              color: AppColors.primary,
              // Was an empty callback — the button rendered and did nothing.
              // Opens the same dialog ChangeVisitDialog already routes to.
              onPressed: () => showDialog(
                context: context,
                builder: (_) => BlocProvider(
                  create: (_) => getIt<ChangeAssessmentCubit>(),
                  child: ChangeLocationDialog(assessmentId: assessmentId),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomOutlinedButton(
              text: LocaleKeys.visits_change_time_button.tr(),
              onPressed: () {
                showRescheduleDialog(context, assessmentId);
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  /// The response has carried the specialist under a few different shapes; a
  /// missing name is left blank rather than filled with a stand-in person.
  static String _specialistName(Map<String, dynamic> summary) {
    final specialist = summary['specialist'];
    return _string(
      summary['specialistName'] ??
          (specialist is Map ? specialist['name'] : null),
    );
  }

  /// `goal` arrives as one bullet-separated string.
  static List<String> _goals(dynamic raw) {
    final text = _string(raw);
    if (text.isEmpty) return const [];
    return text
        .split('•')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
