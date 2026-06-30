import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';

enum AppSegmentedControlType { separated, unified }

class AppSegmentedControl extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final AppSegmentedControlType type;

  const AppSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.type = AppSegmentedControlType.separated,
  });

  @override
  Widget build(BuildContext context) {
    if (type == AppSegmentedControlType.separated) {
      return Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => onItemSelected(i),
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? AppColors.primary
                        : AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: AppShadows.primaryShadow,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    items[i],
                    style: TextStyleManager.style11Medium.copyWith(
                      color: selectedIndex == i
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            if (i != items.length - 1) SizedBox(width: 12.w),
          ],
        ],
      );
    }

    return Container(
      height: 45.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / items.length;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Sliding Thumb (Wider from both sides)
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                start:
                    (selectedIndex *
                    tabWidth), // Shift start to make it overflow
                top: -1, // Cover top border
                bottom: -1, // Cover bottom border
                width: tabWidth, // Make it wider from both sides
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.lightGreenBackground2,
                        AppColors.lightGreenBorder2,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: AppShadows.primaryShadow,
                  ),
                ),
              ),

              // Interactive Text Row
              Row(
                children: [
                  for (int i = 0; i < items.length; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onItemSelected(i),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyleManager.style11Medium.copyWith(
                              color: selectedIndex == i
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                            child: Text(items[i]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
