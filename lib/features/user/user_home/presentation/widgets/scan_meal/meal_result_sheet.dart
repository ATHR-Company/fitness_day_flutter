import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/data/models/meal_analysis_model.dart';

/// Shows the meal analysis result in a scrollable bottom sheet.
Future<void> showMealResultSheet(
  BuildContext context,
  MealAnalysisResult result,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MealResultSheet(result: result),
  );
}

class _MealResultSheet extends StatelessWidget {
  const _MealResultSheet({required this.result});

  final MealAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            children: [
              const _DragHandle(),

              // The model may not have named the meal — fall back to our own
              // label so the sheet never opens with an empty title.
              Text(
                result.mealName.isNotEmpty
                    ? result.mealName
                    : 'scan_meal.result.unknown_meal'.tr(),
                style: TextStyleManager.heading3
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 16.h),

              _MacrosRow(result: result),
              SizedBox(height: 20.h),

              if (result.ingredients.isNotEmpty) ...[
                Text(
                  'scan_meal.result.ingredients'.tr(),
                  style: TextStyleManager.style11Medium
                      .copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8.h),
                ...result.ingredients.map(
                  (ingredient) => _IngredientRow(ingredient: ingredient),
                ),
              ],

              if (result.notes?.isNotEmpty ?? false) ...[
                SizedBox(height: 16.h),
                _NotesCard(notes: result.notes!),
              ],

              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    );
  }
}

class _MacrosRow extends StatelessWidget {
  final MealAnalysisResult result;

  const _MacrosRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final String grams = 'scan_meal.result.gram_short'.tr();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MacroItem(
          label: 'scan_meal.result.calories'.tr(),
          value: result.calories.toStringAsFixed(0),
        ),
        _MacroItem(
          label: 'scan_meal.result.protein'.tr(),
          value: '${result.protein.toStringAsFixed(0)}$grams',
        ),
        _MacroItem(
          label: 'scan_meal.result.carbs'.tr(),
          value: '${result.carbs.toStringAsFixed(0)}$grams',
        ),
        _MacroItem(
          label: 'scan_meal.result.fat'.tr(),
          value: '${result.fat.toStringAsFixed(0)}$grams',
        ),
      ],
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;

  const _MacroItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyleManager.heading3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyleManager.style11Medium
              .copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final MealIngredient ingredient;

  const _IngredientRow({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '${ingredient.name} (${ingredient.approxAmount})',
              style: TextStyleManager.style11Medium,
              textAlign: TextAlign.start,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'scan_meal.result.calorie_amount'.tr(
              namedArgs: {'count': ingredient.calories.toStringAsFixed(0)},
            ),
            style: TextStyleManager.style11Medium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        notes,
        style: TextStyleManager.style11Medium
            .copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.start,
      ),
    );
  }
}
