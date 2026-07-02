import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class VerticalTabBar extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const VerticalTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      decoration: BoxDecoration(
        color: AppColors.backgroundTint,
        borderRadius: BorderRadiusDirectional.horizontal(start: Radius.circular(20.r)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onItemSelected(index),
            child: Container(
              height: 70.h,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: isSelected && index == 0
                    ? BorderRadiusDirectional.only(topStart: Radius.circular(20.r))
                    :  isSelected && index == items.length - 1? BorderRadiusDirectional.only(bottomStart: Radius.circular(20.r)) : null,
                border: !isSelected && index < items.length - 1
                    ? const Border(
                        bottom: BorderSide(color: AppColors.white, width: 1),
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  items[index].replaceAll(' ', '\n'), // Put day name and number on separate lines
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style10Medium.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
