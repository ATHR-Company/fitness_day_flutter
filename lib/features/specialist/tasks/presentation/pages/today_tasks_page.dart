import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import 'package:fitness_day/features/specialist/tasks/presentation/manager/specialist_daily_tasks_cubit.dart';
import 'package:fitness_day/features/specialist/tasks/presentation/manager/specialist_daily_tasks_state.dart';
import '../../../visits/presentation/pages/visit_details_page.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';

class TodayTasksPage extends StatelessWidget {
  const TodayTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<SpecialistDailyTasksCubit>()..getDailyTasks(),
      child: const _TodayTasksPageContent(),
    );
  }
}

class _TodayTasksPageContent extends StatefulWidget {
  const _TodayTasksPageContent();

  @override
  State<_TodayTasksPageContent> createState() => _TodayTasksPageContentState();
}

class _TodayTasksPageContentState extends State<_TodayTasksPageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SpecialistDailyTasksCubit>().loadMoreDailyTasks();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go(SpecialistAppRoutes.home);
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.profileGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          endDrawer: const AppDrawer(),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Builder(
                  builder: (context) => AppHeader(
                    title: 'drawer.today_tasks'.tr(),
                    onMenuPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ),
              SizedBox(height: 16.h),
              Expanded(
                child: BlocBuilder<SpecialistDailyTasksCubit, SpecialistDailyTasksState>(
                  builder: (context, state) {
                    if (state is SpecialistDailyTasksLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SpecialistDailyTasksFailure) {
                      return AppErrorView(
                        error: state.error,
                        message: state.message,
                        onRetry: () => context
                            .read<SpecialistDailyTasksCubit>()
                            .getDailyTasks(),
                      );
                    } else if (state is SpecialistDailyTasksSuccess ||
                        state is SpecialistDailyTasksLoadingMore) {
                      final tasks = state is SpecialistDailyTasksSuccess
                          ? state.tasks
                          : (state as SpecialistDailyTasksLoadingMore).tasks;

                      if (tasks.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.groups_rounded,
                                  size: 120.sp,
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                ),
                                SizedBox(height: 24.h),
                                Text(
                                  'visits.no_tasks'.tr(),
                                  style: TextStyleManager.style16Bold.copyWith(
                                    color: AppColors.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'clients_page.empty_subtitle'.tr(),
                                  style: TextStyleManager.style13Medium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => context
                            .read<SpecialistDailyTasksCubit>()
                            .getDailyTasks(isRefresh: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(20.h),
                          itemCount: tasks.length + (state is SpecialistDailyTasksLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= tasks.length) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            }

                            final task = tasks[index];

                            String formattedTime = '';
                            if (task.weekStart.isNotEmpty) {
                              final parsed = DateTime.tryParse(task.weekStart);
                              if (parsed != null) {
                                formattedTime = DateFormat('yyyy-MM-dd hh:mm a', context.locale.languageCode)
                                    .format(parsed.toLocal());
                              }
                            }
                            if (formattedTime.isEmpty) {
                              formattedTime = task.weekStart;
                            }

                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: VisitCard(
                                isUpcoming: true,
                                timeRemaining: task.user != null
                                    ? "home.commitment_rate".tr(args: [task.user!.adherenceRate.toInt().toString()])
                                    : '',
                                title: task.name,
                                subtitle: task.description,
                                personName: task.user?.name ?? '',
                                visitTime: formattedTime,
                                location: task.placement,
                                buttonText: 'home.view_visit'.tr(),
                                onViewPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VisitDetailsPage(
                                        isUpcoming: true,
                                        assessmentId: task.assessmentId,
                                      ),
                                    ),
                                  );
                                },
                                iconPath: task.image.isNotEmpty ? task.image : SvgIcons.needMonitor,
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
  }

