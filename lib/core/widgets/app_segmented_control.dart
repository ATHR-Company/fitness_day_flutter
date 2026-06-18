import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: selectedIndex == i ? AppColors.primary : AppColors.backgroundTint,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    items[i],
                    style: TextStyleManager.style14Medium.copyWith(
                      color: selectedIndex == i ? AppColors.white : AppColors.textSecondary,
                      fontWeight: selectedIndex == i ? FontWeight.bold : FontWeight.normal,
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
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
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
                start: (selectedIndex * tabWidth) - 6.w, // Shift start to make it overflow
                top: -1, // Cover top border
                bottom: -1, // Cover bottom border
                width: tabWidth + 12.w, // Make it wider from both sides
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEBF8ED),
                        Color(0xFFD2F0D5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 0),
                      ),
                    ],
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
                              color: selectedIndex == i ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: selectedIndex == i ? FontWeight.bold : FontWeight.normal,
                              fontFamily: TextStyleManager.style11Medium.fontFamily, // Ensure font family is explicitly kept during animation
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
