import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/vertical_tab_bar.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/diet_plan_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/diet_plan_state.dart';
import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:go_router/go_router.dart';

class DietPlanPage extends StatefulWidget {
  const DietPlanPage({super.key});

  @override
  State<DietPlanPage> createState() => _DietPlanPageState();
}

class _DietPlanPageState extends State<DietPlanPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedDayIndex = 0;

  List<TaskData> _mapMealsToTasks(BuildContext context, List<MealItem> meals) {
    return meals.map((meal) {
      String categoryTitle = meal.categoryName;
      if (meal.categoryName.toLowerCase() == 'breakfast') {
        categoryTitle = 'وجبة الافطار';
      } else if (meal.categoryName.toLowerCase() == 'lunch') {
        categoryTitle = 'وجبة الغداء';
      } else if (meal.categoryName.toLowerCase() == 'dinner') {
        categoryTitle = 'وجبة العشاء';
      }

      String time = '8:00 صباحاً';
      if (meal.categoryName.toLowerCase() == 'lunch') {
        time = '3:00 ظهراً';
      } else if (meal.categoryName.toLowerCase() == 'dinner') {
        time = '8:00 مساءً';
      }

      final isAr = context.locale.languageCode == 'ar';
      final calorieUnit = isAr ? 'كالورى' : 'kcal';

      return TaskData(
        imagePath: meal.image,
        title: isAr ? categoryTitle : meal.categoryName,
        description: meal.name,
        time: time,
        extraLabel: meal.calories.toString(),
        extraUnit: calorieUnit,
        extraIcon: Icons.local_fire_department,
        done: false,
        onDetailsPressed: () {
          context.push(UserAppRoutes.mealDetails, extra: {
            'mealId': meal.id,
            'assessmentId': getIt<AppCache>().getAssessmentId() ?? '',
            'dayNumber': _selectedDayIndex + 1,
          });
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DietPlanCubit>()..getDietPlan(_selectedDayIndex + 1),
      child: Builder(
        builder: (context) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.scaffoldBackground,
            endDrawer: const UserAppDrawer(),
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
                              child: _buildEmptyState(),
                            );
                          }
                          final tasks = _mapMealsToTasks(context, meals);
                          return _buildLayoutWithTabBar(
                            context,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 16.w, 24.h),
                              child: Column(
                                children: [
                                  _buildSectionTitle(
                                    LocaleKeys.visit_details_nutrition.tr(),
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
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.r),
                                child: Text(
                                  state.message,
                                  style: TextStyleManager.style14Medium.copyWith(
                                    color: AppColors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
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
    );
  }

  Widget _buildLayoutWithTabBar(BuildContext context, {required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content Area
        Expanded(child: child),
        // Vertical Day Tab Bar
        VerticalTabBar(
          items: [
            LocaleKeys.visit_details_day_1.tr(),
            LocaleKeys.visit_details_day_2.tr(),
            LocaleKeys.visit_details_day_3.tr(),
            LocaleKeys.visit_details_day_4.tr(),
            LocaleKeys.visit_details_day_5.tr(),
            LocaleKeys.visit_details_day_6.tr(),
            LocaleKeys.visit_details_day_7.tr(),
          ],
          selectedIndex: _selectedDayIndex,
          onItemSelected: (index) {
            setState(() {
              _selectedDayIndex = index;
            });
            context.read<DietPlanCubit>().getDietPlan(index + 1);
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
            AppImage(SvgIcons.noDiet),
            SizedBox(height: 24.h),
            Text(
              'diet_plan.empty_title'.tr(),
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'diet_plan.empty_subtitle'.tr(),
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
