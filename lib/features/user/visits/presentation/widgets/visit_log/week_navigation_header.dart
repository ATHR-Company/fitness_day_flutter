import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Week range label with previous/next navigation arrows.
/// Arrow direction automatically flips for RTL vs LTR locales.
class WeekNavigationHeader extends StatelessWidget {
  final DateTime weekStart;
  final DateTime weekEnd;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isPreviousEnabled;
  final bool isNextEnabled;

  const WeekNavigationHeader({
    super.key,
    required this.weekStart,
    required this.weekEnd,
    required this.onPrevious,
    required this.onNext,
    required this.isPreviousEnabled,
    required this.isNextEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMM', context.locale.languageCode);
    final yearFormatter = DateFormat('yyyy', 'en');
    final label =
        '${formatter.format(weekStart)} – ${formatter.format(weekEnd)}  ${yearFormatter.format(weekStart)}';

    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundTint,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous week (points toward reading-start direction)
          CalNavArrow(
            icon: isRtl ? Icons.chevron_left : Icons.chevron_left,
            onTap: onPrevious,
            enabled: isPreviousEnabled,
          ),
          Flexible(
            child: Text(
              label,
              style: TextStyleManager.style12Regular.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Next week (points toward reading-end direction)
          CalNavArrow(
            icon: isRtl ? Icons.chevron_right : Icons.chevron_right,
            onTap: onNext,
            enabled: isNextEnabled,
          ),
        ],
      ),
    );
  }
}

/// Small circular tap target used for the previous/next week arrows.
class CalNavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const CalNavArrow({
    super.key,
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: enabled ? AppColors.white : AppColors.divider.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, size: 22.sp, color: enabled ? AppColors.primary : AppColors.divider),
      ),
    );
  }
}
