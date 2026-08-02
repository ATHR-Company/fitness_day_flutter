import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:fitness_day/features/specialist/clients/data/models/client_assessment_model.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/client_assessments_cubit.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/client_assessments_state.dart';
import 'package:fitness_day/features/specialist/visits/presentation/pages/visit_details_page.dart';

class ClientVisitsTab extends StatefulWidget {
  final String userId;

  const ClientVisitsTab({super.key, required this.userId});

  @override
  State<ClientVisitsTab> createState() => _ClientVisitsTabState();
}

class _ClientVisitsTabState extends State<ClientVisitsTab> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientAssessmentsCubit>(
      create: (_) => getIt<ClientAssessmentsCubit>()..loadAssessments(userId: widget.userId),
      child: BlocBuilder<ClientAssessmentsCubit, ClientAssessmentsState>(
        builder: (context, state) {
          if (state is ClientAssessmentsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ClientAssessmentsFailure) {
            return AppErrorView(
              error: state.error,
              message: state.message,
              onRetry: () => context.read<ClientAssessmentsCubit>().loadAssessments(userId: widget.userId),
            );
          }

          if (state is ClientAssessmentsSuccess) {
            final isUpcoming = _selectedTabIndex == 0;
            final visits = isUpcoming ? state.upcoming : state.previous;

            return Column(
              children: [
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: AppSegmentedControl(
                    items: [
                      'visits.tab_upcoming'.tr(), // index 0
                      'visits.tab_history'.tr(),  // index 1
                    ],
                    selectedIndex: _selectedTabIndex,
                    onItemSelected: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: visits.isEmpty
                      ? Center(
                          child: Text(
                            isUpcoming
                                ? 'clients_page.no_upcoming_visits'.tr()
                                : 'clients_page.no_past_visits'.tr(),
                            style: TextStyleManager.style13Medium.copyWith(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          itemCount: visits.length,
                          itemBuilder: (context, index) {
                            final visit = visits[index];
                            return _buildVisitCard(context, visit, isUpcoming: isUpcoming);
                          },
                        ),
                ),
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
              builder: (_) => VisitDetailsPage(
                isUpcoming: isUpcoming,
                assessmentId: a.assessmentId ?? '',
              ),
            ),
          );
        },
        secondaryButtonText: isUpcoming ? 'home.reschedule'.tr() : null,
        onSecondaryPressed: isUpcoming ? () {} : null,
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
