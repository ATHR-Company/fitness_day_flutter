import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/info_table_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/meal_details_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/meal_details_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

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

                  // Parse ingredients into description format
                  final descriptionText = data.ingredients
                      .map((ing) => '${ing.name}: ${ing.quantity % 1 == 0 ? ing.quantity.toInt() : ing.quantity} ${ing.unit}')
                      .join('\n');

                  // Sort preparation steps by order just in case
                  final sortedSteps = List.of(data.preparationSteps)
                    ..sort((a, b) => a.order.compareTo(b.order));
                  final preparationStepsList = sortedSteps.map((step) => step.text).toList();

                  // Parse nutrition values into table rows
                  final tableData = data.nutrition.map((nut) {
                    String label = nut.key;
                    final isAr = context.locale.languageCode == 'ar';
                    if (nut.key.toLowerCase() == 'calories') {
                      label = isAr ? 'السعرات بالكالوري' : 'Calories (kcal)';
                    } else if (nut.key.toLowerCase() == 'fat') {
                      label = isAr ? 'الدهون بالجرام' : 'Fat (g)';
                    } else if (nut.key.toLowerCase() == 'carbohydrates') {
                      label = isAr ? 'الكربوهيدرات بالجرام' : 'Carbohydrates (g)';
                    } else if (nut.key.toLowerCase() == 'sugar') {
                      label = isAr ? 'سكر بالجرام' : 'Sugar (g)';
                    } else if (nut.key.toLowerCase() == 'protein') {
                      label = isAr ? 'البروتين بالجرام' : 'Protein (g)';
                    } else if (nut.key.toLowerCase() == 'fiber') {
                      label = isAr ? 'الالياف بالجرام' : 'Fiber (g)';
                    } else if (nut.key.toLowerCase() == 'cholesterol') {
                      label = isAr ? 'كوليسترول بالجرام' : 'Cholesterol (g)';
                    }

                    String valStr = nut.value.toString();
                    if (nut.value == nut.value.toInt()) {
                      valStr = nut.value.toInt().toString();
                    }

                    return TableRowData(label: label, value: valStr);
                  }).toList();

                  final isAr = context.locale.languageCode == 'ar';

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        // Header
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: AppBackHeader(
                            title: isAr ? 'تفاصيل الوجبة' : 'Meal Details',
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          isAr ? 'مضافة بواسطة يوم الرشاقة' : 'Added by Fitness Day',
                          style: TextStyleManager.style11Medium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Circular Image
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(data.image),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 4.w,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Meal Name
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            data.name,
                            textAlign: TextAlign.center,
                            style: TextStyleManager.heading2.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Description
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            descriptionText,
                            textAlign: TextAlign.center,
                            style: TextStyleManager.style11Medium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Calories Pill
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            gradient: AppColors.timeRemainingGradient,
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isAr ? 'كالوري' : 'Calories',
                                style: TextStyleManager.style11Medium.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                data.calories.toString(),
                                style: TextStyleManager.style16Bold.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text('🔥', style: TextStyleManager.style16Bold),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Preparation Method
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: VisitGoalCard(
                            title: isAr ? 'طريقة التحضير :' : 'Preparation Method:',
                            goals: preparationStepsList,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Food Data Table
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: InfoTableCard(
                            title: isAr ? 'بيانات الطعام' : 'Nutrition Facts',
                            data: tableData,
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  );
                } else if (state is MealDetailsFailure) {
                  final isAr = context.locale.languageCode == 'ar';
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.message,
                            style: TextStyleManager.style14Medium.copyWith(
                              color: AppColors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => context.pop(),
                            child: Text(isAr ? 'رجوع' : 'Back'),
                          ),
                        ],
                      ),
                    ),
                  );
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
