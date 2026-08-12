import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/vertical_day_tab_bar.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/utils/date_time_utils.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/diet_plan_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/diet_plan_state.dart';
import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/diet_plan/diet_plan_empty_state.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/shared/visits_section_title.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';

class DietPlanPage extends StatefulWidget {
  const DietPlanPage({super.key});

  @override
  State<DietPlanPage> createState() => _DietPlanPageState();
}

class _DietPlanPageState extends State<DietPlanPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedDayIndex = 0;

  List<TaskData> _mapMealsToTasks(
      BuildContext context, List<MealItem> meals, String assessmentId) {
    return meals.map((meal) {
      String categoryTitle = meal.categoryName;
      if (meal.categoryName.toLowerCase() == 'breakfast') {
        categoryTitle = LocaleKeys.add_meal_breakfast.tr();
      } else if (meal.categoryName.toLowerCase() == 'lunch') {
        categoryTitle = LocaleKeys.add_meal_lunch.tr();
      } else if (meal.categoryName.toLowerCase() == 'dinner') {
        categoryTitle = LocaleKeys.add_meal_dinner.tr();
      }

      String time = formatPlanClockIso(meal.time);

      if (time.isEmpty) {
        time = LocaleKeys.diet_plan_default_breakfast_time.tr();
        if (meal.categoryName.toLowerCase() == 'lunch') {
          time = LocaleKeys.diet_plan_default_lunch_time.tr();
        } else if (meal.categoryName.toLowerCase() == 'dinner') {
          time = LocaleKeys.diet_plan_default_dinner_time.tr();
        }
      }

      final isAr = context.locale.languageCode == 'ar';
      final calorieUnit = LocaleKeys.visit_details_kcal.tr();

      return TaskData(
        imagePath: meal.image,
        title: isAr ? categoryTitle : meal.categoryName,
        description: meal.name,
        time: time,
        extraLabel: meal.calories % 1 == 0 ? meal.calories.toInt().toString() : meal.calories.toStringAsFixed(1),
        extraUnit: calorieUnit,
        extraIcon: Icons.local_fire_department,
        done: meal.isCompleted,
        onDetailsPressed: () {
          context.push(UserAppRoutes.mealDetails, extra: {
            'mealId': meal.id,
            'assessmentId': assessmentId.isNotEmpty
                ? assessmentId
                : (getIt<AppCache>().getAssessmentId() ?? ''),
            'dayNumber': _selectedDayIndex + 1,
          });
          // No refetch on the way back — MealDetailsCubit publishes the
          // server-confirmed completion to AppEventBus and DietPlanCubit
          // ticks this meal from it.
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
        create: (context) => getIt<DietPlanCubit>()..getDietPlan(_selectedDayIndex + 1),
        child: Builder(
          builder: (context) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.scaffoldBackground,
            endDrawer: UserAppDrawer(isSubscribed: getIt<AppCache>().getIsSubscribed()),
            body: SafeArea(
              child: Column(
                children: [
                  AppHeader(
                    title: LocaleKeys.drawer_diet_plan.tr(),
                    onMenuPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: BlocBuilder<DietPlanCubit, DietPlanState>(
                      builder: (context, state) {
                        if (state is DietPlanLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        } else if (state is DietPlanSuccess) {
                          final meals = state.dietPlanData?.meals ?? [];
                          if (meals.isEmpty) {
                            return _buildLayoutWithTabBar(
                              context,
                              child: const DietPlanEmptyState(),
                            );
                          }
                          final tasks = _mapMealsToTasks(
                              context, meals, state.dietPlanData?.assessmentId ?? '');
                          return _buildLayoutWithTabBar(
                            context,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 16.w, 24.h),
                              child: Column(
                                children: [
                                  VisitsSectionTitle(
                                    title: LocaleKeys.visit_details_nutrition.tr(),
                                  ),
                                  SizedBox(height: 12.h),
                                  TodayTasksSection(tasks: tasks),
                                ],
                              ),
                            ),
                          );
                        } else if (state is DietPlanFailure) {
                          return _buildLayoutWithTabBar(
                            context,
                            child: AppErrorView(
                              error: state.error,
                              message: state.message,
                              onRetry: () => context
                                  .read<DietPlanCubit>()
                                  .getDietPlan(_selectedDayIndex + 1),
                            ),
                          );
                        }
                        return _buildLayoutWithTabBar(
                          context,
                          child: const DietPlanEmptyState(),
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
            context.read<DietPlanCubit>().getDietPlan(index + 1);
          },
        ),
      ],
    );
  }
}
