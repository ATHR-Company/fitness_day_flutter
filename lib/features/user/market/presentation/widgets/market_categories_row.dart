import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';

/// Horizontally scrollable pill selector for product categories.
class MarketCategoriesRow extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const MarketCategoriesRow({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(categories.length, (index) {
              final isSelected = selectedIndex == index;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: GestureDetector(
                  onTap: () => onSelect(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: AppColors.backgroundTint,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: AppShadows.primaryShadow,
                          )
                        : BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                    child: Text(
                      categories[index],
                      style: TextStyleManager.style11Medium.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
