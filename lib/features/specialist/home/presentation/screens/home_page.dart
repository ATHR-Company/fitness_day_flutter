import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/features/specialist/home/presentation/widgets/home_header.dart';
import 'package:fitness_day/features/specialist/home/presentation/widgets/performance_summary_section.dart';
import 'package:fitness_day/features/specialist/home/presentation/widgets/section_header.dart';
import 'package:fitness_day/features/specialist/home/presentation/widgets/follow_up_alert_card.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';
import 'package:fitness_day/features/specialist/visits/presentation/pages/visit_details_page.dart';
import 'package:fitness_day/core/widgets/exit_dialog.dart';
import 'package:fitness_day/features/specialist/clients/presentation/pages/client_profile_page.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import 'package:fitness_day/features/specialist/home/presentation/manager/specialist_home_cubit.dart';
import 'package:fitness_day/features/specialist/home/presentation/manager/specialist_home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<SpecialistHomeCubit>()..getSpecialistHomeData(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          showDialog(
            context: context,
            builder: (context) => const ExitDialog(),
          );
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: AppBar(
              elevation: 0,
              backgroundColor: AppColors.headerBackground,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
            ),
          ),
          endDrawer: const AppDrawer(),
          body: SafeArea(
            child: BlocBuilder<SpecialistHomeCubit, SpecialistHomeState>(
              builder: (context, state) {
                if (state is SpecialistHomeLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                } else if (state is SpecialistHomeFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: TextStyleManager.style14Medium.copyWith(color: AppColors.error),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => context.read<SpecialistHomeCubit>().getSpecialistHomeData(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: Text(
                            "common.retry".tr(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is SpecialistHomeSuccess) {
                  final data = state.data;
                  final summary = data.performanceSummary;
                  return RefreshIndicator(
                    onRefresh: () => context.read<SpecialistHomeCubit>().getSpecialistHomeData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Header Area
                          HomeHeader(
                            name: data.name,
                            branch: data.branch,
                            avatarUrl: data.avatar,
                          ),

                          SizedBox(height: 24.h),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: PerformanceSummarySection(
                              dailyVisitsCount: summary?.dailyVisitsCount ?? 0,
                              needsFollowUpCount: summary?.needsFollowUpCount ?? 0,
                              clientsCount: summary?.clientsCount ?? 0,
                            ),
                          ),

                          SizedBox(height: 24.h),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              children: [
                                if (data.upcomingAssessments.isNotEmpty) ...[
                                  SectionHeader(
                                    title: "home.upcoming_appointments".tr(),
                                  ),
                                  SizedBox(height: 16.h),
                                  ...data.upcomingAssessments.map((assessment) {
                                    String formattedTime = '';
                                    if (assessment.weekStart.isNotEmpty) {
                                      final parsed = DateTime.tryParse(assessment.weekStart);
                                      if (parsed != null) {
                                        formattedTime = DateFormat('yyyy-MM-dd hh:mm a', context.locale.languageCode)
                                            .format(parsed.toLocal());
                                      }
                                    }
                                    if (formattedTime.isEmpty) {
                                      formattedTime = assessment.weekStart;
                                    }

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 16.h),
                                      child: VisitCard(
                                        timeRemaining: "home.commitment_rate".tr(
                                          args: [assessment.user?.adherenceRate.toString() ?? '0'],
                                        ),
                                        title: assessment.name,
                                        subtitle: assessment.description,
                                        personName: assessment.user?.name ?? '',
                                        visitTime: formattedTime,
                                        location: assessment.placement,
                                        iconPath: assessment.image.isNotEmpty ? assessment.image : SvgIcons.monitor,
                                        buttonText: "home.view_visit".tr(),
                                        onViewPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const VisitDetailsPage(isUpcoming: true),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                ],

                                if (data.needsFollowUp != null) ...[
                                  SizedBox(height: 24.h),
                                  SectionHeader(
                                    title: "home.clients_need_follow_up".tr(),
                                  ),
                                  SizedBox(height: 16.h),
                                  FollowUpAlertCard(
                                    title: "home.needs_follow_up".tr(),
                                    clientName: data.needsFollowUp!.name,
                                    alertReason: data.needsFollowUp!.reason,
                                    buttonText: 'clients_page.view_profile'.tr(),
                                    iconPath: data.needsFollowUp!.image.isNotEmpty ? data.needsFollowUp!.image : SvgIcons.needMonitorRed,
                                    onButtonPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ClientProfilePage(
                                            userId: data.needsFollowUp!.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),

                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }
}
