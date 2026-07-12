import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'meal_analysis_model.dart';

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
              // ── Drag handle ──────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),

              // ── Meal name ────────────────────────────────────────────────
              Text(
                result.mealName,
                style: TextStyleManager.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 16.h),

              // ── Macros row ───────────────────────────────────────────────
              _buildMacrosRow(result),
              SizedBox(height: 20.h),

              // ── Ingredients ──────────────────────────────────────────────
              if (result.ingredients.isNotEmpty) ...[
                Text(
                  'المكونات',
                  style: TextStyleManager.style11Medium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8.h),
                ...result.ingredients.map(
                  (i) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      children: [
                        Text(
                          '${i.calories.toStringAsFixed(0)} سعرة',
                          style: TextStyleManager.style11Medium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${i.name} (${i.approxAmount})',
                          style: TextStyleManager.style11Medium,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Notes ────────────────────────────────────────────────────
              if (result.notes != null && result.notes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    result.notes!,
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],

              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacrosRow(MealAnalysisResult r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _macroItem('سعرات', r.calories.toStringAsFixed(0)),
        _macroItem('بروتين', '${r.protein.toStringAsFixed(0)}جم'),
        _macroItem('كارب', '${r.carbs.toStringAsFixed(0)}جم'),
        _macroItem('دهون', '${r.fat.toStringAsFixed(0)}جم'),
      ],
    );
  }

  Widget _macroItem(String label, String value) {
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
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
