import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/specialist/clients/data/models/client_assessment_model.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/client_assessments_cubit.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/client_assessments_state.dart';
import 'package:fitness_day/features/specialist/visits/presentation/pages/visit_details_page.dart';

class ClientVisitsTab extends StatelessWidget {
  final String userId;

  const ClientVisitsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientAssessmentsCubit>(
      create: (_) => getIt<ClientAssessmentsCubit>()..loadAssessments(userId: userId),
      child: BlocBuilder<ClientAssessmentsCubit, ClientAssessmentsState>(
        builder: (context, state) {
          if (state is ClientAssessmentsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ClientAssessmentsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyleManager.style13Medium.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<ClientAssessmentsCubit>().loadAssessments(userId: userId),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text('common.retry'.tr(), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (state is ClientAssessmentsSuccess) {
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              children: [
                // ── Upcoming ──────────────────────────────────────────
                Text('clients_page.upcoming_visit'.tr(), style: TextStyleManager.style14Bold),
                SizedBox(height: 10.h),
                if (state.upcoming.isEmpty)
                  _buildEmpty('clients_page.no_upcoming_visits'.tr())
                else
                  ...state.upcoming.map((a) => _buildVisitCard(context, a, isUpcoming: true)),

                SizedBox(height: 20.h),

                // ── Previous ──────────────────────────────────────────
                Text('clients_page.past_visits'.tr(), style: TextStyleManager.style14Bold),
                SizedBox(height: 10.h),
                if (state.previous.isEmpty)
                  _buildEmpty('clients_page.no_past_visits'.tr())
                else
                  ...state.previous.map((a) => _buildVisitCard(context, a, isUpcoming: false)),

                SizedBox(height: 24.h),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, ClientAssessmentModel a, {required bool isUpcoming}) {
    final formattedDate = _formatDate(a.weekStart);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: VisitCard(
        timeRemaining: a.user?.adherenceRate != null
            ? 'clients_page.commitment_rate'.tr(args: [a.user!.adherenceRate!.toInt().toString()])
            : '',
        title: a.name ?? '',
        subtitle: a.description ?? '',
        personName: a.user?.name ?? '',
        visitTime: formattedDate,
        location: a.placement ?? '',
        iconPath: a.image ?? '',
        isUpcoming: isUpcoming,
        buttonText: isUpcoming ? 'home.view_visit'.tr() : 'clients_page.details'.tr(),
        onViewPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VisitDetailsPage(isUpcoming: isUpcoming),
            ),
          );
        },
        secondaryButtonText: isUpcoming ? 'home.reschedule'.tr() : null,
        onSecondaryPressed: isUpcoming ? () {} : null,
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(
        message,
        style: TextStyleManager.style13Medium.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }
}
