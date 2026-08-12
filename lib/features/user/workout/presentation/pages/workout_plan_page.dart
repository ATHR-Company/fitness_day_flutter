import 'package:fitness_day/core/entities/task_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/vertical_day_tab_bar.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/utils/date_time_utils.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/features/user/workout/presentation/manager/workout_plan_cubit.dart';
import 'package:fitness_day/features/user/workout/presentation/manager/workout_plan_state.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_plan_model.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/widgets/exercise_details_dialog.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';

class WorkoutPlanPage extends StatefulWidget {
  const WorkoutPlanPage({super.key});

  @override
  State<WorkoutPlanPage> createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedDayIndex = 0;

  List<TaskData> _mapWorkoutsToTasks(
      BuildContext context, List<WorkoutItemModel> workouts, String assessmentId) {
    return workouts.map((workout) {
      final isAr = context.locale.languageCode == 'ar';
      final setsUnit = isAr ? 'مجموعات' : 'sets';

      final String formattedTime = formatPlanClockIso(workout.time);

      return TaskData(
        imagePath: workout.photo,
        title: workout.name,
        description: workout.description,
        time: formattedTime,
        extraLabel: '${workout.completedSets}/${workout.totalSets}',
        extraUnit: setsUnit,
        extraIcon: Icons.fitness_center,
        done: workout.isCompleted,
        onDetailsPressed: () {
          showDialog(
            context: context,
            builder: (_) => ExerciseDetailsDialog(
              workoutItemId: workout.id,
              assessmentId: assessmentId,
              dayNumber: _selectedDayIndex + 1,
            ),
          );
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(UserAppRoutes.home);
        }
      },
      child: BlocProvider(
        create: (context) => getIt<WorkoutPlanCubit>()..getWorkoutPlan(_selectedDayIndex + 1),
        child: Builder(
          builder: (context) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColors.scaffoldBackground,
              endDrawer: UserAppDrawer(isSubscribed: getIt<AppCache>().getIsSubscribed()),
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    AppHeader(
                      title: LocaleKeys.drawer_workout_plan.tr(),
                      onMenuPressed: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
                        builder: (context, state) {
                          if (state is WorkoutPlanLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          } else if (state is WorkoutPlanSuccess) {
                            final workouts = state.workoutPlanData?.workouts ?? [];
                            if (workouts.isEmpty) {
                              return _buildLayoutWithTabBar(
                                context,
                                child: _buildEmptyState(),
                              );
                            }
                            final tasks = _mapWorkoutsToTasks(
                                context, workouts, state.workoutPlanData?.assessmentId ?? '');
                            return _buildLayoutWithTabBar(
                              context,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.fromLTRB(20.w, 0, 16.w, 24.h),
                                child: Column(
                                  children: [
                                    _buildSectionTitle(
                                      LocaleKeys.workout_exercises.tr(),
                                    ),
                                    SizedBox(height: 12.h),
                                    TodayTasksSection(tasks: tasks),
                                  ],
                                ),
                              ),
                            );
                          } else if (state is WorkoutPlanFailure) {
                            return _buildLayoutWithTabBar(
                              context,
                              child: AppErrorView(
                                error: state.error,
                                message: state.message,
                                onRetry: () => context
                                    .read<WorkoutPlanCubit>()
                                    .getWorkoutPlan(_selectedDayIndex + 1),
                              ),
                            );
                          }
                          return _buildLayoutWithTabBar(
                            context,
                            child: _buildEmptyState(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLayoutWithTabBar(BuildContext context, {required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content Area
        Expanded(child: child),
        // Vertical Day Tab Bar
        VerticalDayTabBar(
          days: [
            LocaleKeys.visit_details_day_1.tr(),
            LocaleKeys.visit_details_day_2.tr(),
            LocaleKeys.visit_details_day_3.tr(),
            LocaleKeys.visit_details_day_4.tr(),
            LocaleKeys.visit_details_day_5.tr(),
            LocaleKeys.visit_details_day_6.tr(),
            LocaleKeys.visit_details_day_7.tr(),
          ],
          selectedIndex: _selectedDayIndex,
          onDaySelected: (index) {
            setState(() {
              _selectedDayIndex = index;
            });
            context.read<WorkoutPlanCubit>().getWorkoutPlan(index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_rounded,
              size: 80.r,
              color: AppColors.divider,
            ),
            SizedBox(height: 24.h),
            Text(
              'workout_plan.empty_title'.tr(),
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'workout_plan.empty_subtitle'.tr(),
              style: TextStyleManager.style14Medium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyleManager.heading2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
