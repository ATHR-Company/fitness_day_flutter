import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/info_table_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/meal_details_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/meal_details_state.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/meal_details/meal_details_header.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/meal_details/meal_details_hero.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/meal_details/meal_calories_pill.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/meal_details/meal_complete_button.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/meal_details/meal_details_error_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

class MealDetailsPage extends StatelessWidget {
  final String mealId;
  final String assessmentId;
  final int dayNumber;

  const MealDetailsPage({
    super.key,
    required this.mealId,
    required this.assessmentId,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MealDetailsCubit>()
        ..getMealDetails(assessmentId, dayNumber, mealId),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.splashBackgroundGradient,
          ),
          child: SafeArea(
            child: BlocBuilder<MealDetailsCubit, MealDetailsState>(
              builder: (context, state) {
                if (state is MealDetailsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                } else if (state is MealDetailsSuccess) {
                  final data = state.mealDetailsData;
                  final isUpdating = state.isUpdating;

                  // Parse ingredients into description format
                  final descriptionText = data.ingredients
                      .map((ing) =>
                          '${ing.name}: ${ing.quantity % 1 == 0 ? ing.quantity.toInt() : ing.quantity} ${ing.unit}')
                      .join('\n');

                  // Sort preparation steps by order just in case
                  final sortedSteps = List.of(data.preparationSteps)
                    ..sort((a, b) => a.order.compareTo(b.order));
                  final preparationStepsList =
                      sortedSteps.map((step) => step.text).toList();

                  // Parse nutrition values into table rows
                  final tableData = data.nutrition.map((nut) {
                    String label = nut.key;
                    if (nut.key.toLowerCase() == 'calories') {
                      label = LocaleKeys.meal_details_nutrition_calories.tr();
                    } else if (nut.key.toLowerCase() == 'fat') {
                      label = LocaleKeys.meal_details_nutrition_fat.tr();
                    } else if (nut.key.toLowerCase() == 'carbohydrates') {
                      label = LocaleKeys.meal_details_nutrition_carbohydrates.tr();
                    } else if (nut.key.toLowerCase() == 'sugar') {
                      label = LocaleKeys.meal_details_nutrition_sugar.tr();
                    } else if (nut.key.toLowerCase() == 'protein') {
                      label = LocaleKeys.meal_details_nutrition_protein.tr();
                    } else if (nut.key.toLowerCase() == 'fiber') {
                      label = LocaleKeys.meal_details_nutrition_fiber.tr();
                    } else if (nut.key.toLowerCase() == 'cholesterol') {
                      label = LocaleKeys.meal_details_nutrition_cholesterol.tr();
                    }

                    String valStr = nut.value.toString();
                    if (nut.value == nut.value.toInt()) {
                      valStr = nut.value.toInt().toString();
                    }

                    return TableRowData(label: label, value: valStr);
                  }).toList();

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        const MealDetailsHeader(),
                        SizedBox(height: 24.h),
                        MealDetailsHero(
                          imageUrl: data.image,
                          name: data.name,
                          description: descriptionText,
                        ),
                        SizedBox(height: 16.h),
                        MealCaloriesPill(calories: data.calories),
                        SizedBox(height: 28.h),

                        // Preparation Method
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: VisitGoalCard(
                            title: LocaleKeys.meal_details_preparation_method.tr(),
                            goals: preparationStepsList,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Food Data Table
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: InfoTableCard(
                            title: LocaleKeys.meal_details_nutrition_facts.tr(),
                            data: tableData,
                          ),
                        ),

                        if (data.canEdit) ...[
                          SizedBox(height: 24.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: MealCompleteButton(
                              isCompleted: data.isCompleted,
                              isUpdating: isUpdating,
                              onPressed: () {
                                context.read<MealDetailsCubit>().toggleMealCompletion(
                                      data.assessmentId.isNotEmpty
                                          ? data.assessmentId
                                          : assessmentId,
                                      data.dayNumber > 0
                                          ? data.dayNumber
                                          : dayNumber,
                                      data.id.isNotEmpty ? data.id : mealId,
                                      !data.isCompleted,
                                    );
                              },
                            ),
                          ),
                        ],
                        SizedBox(height: 32.h),
                      ],
                    ),
                  );
                } else if (state is MealDetailsFailure) {
                  return MealDetailsErrorView(message: state.message);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
