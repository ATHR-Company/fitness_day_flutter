import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Period Tab Bar
// ─────────────────────────────────────────────────────────────────────────────

class PeriodTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const PeriodTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final bool sel = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xffDEF4E1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                  border:
                      sel ? Border.all(color: AppColors.divider) : null,
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.09),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: sel ? AppColors.primary : AppColors.black,
                    fontWeight:
                        sel ? FontWeight.bold : FontWeight.w500,
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
