import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';

/// Direction-aware progress bar.
/// LTR: fills from left → right.
/// RTL: fills from right → left.
class AwardProgressBar extends StatelessWidget {
  final double progress; // 0.0 – 1.0

  const AwardProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double filled = (totalWidth * progress).clamp(0.0, totalWidth);
        // Thumb centre sits at the progressed edge
        final double thumbEdge = (filled - 6.r).clamp(0.0, totalWidth - 12.r);

        return SizedBox(
          height: 14.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Track
              Container(
                width: totalWidth,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              // Filled portion — anchored to the leading edge
              Positioned(
                left: isRtl ? null : 0,
                right: isRtl ? 0 : null,
                child: Container(
                  width: filled,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              // Thumb dot — sits at the end of the filled portion
              Positioned(
                left: isRtl ? null : thumbEdge,
                right: isRtl ? thumbEdge : null,
                child: Container(
                  width: 13.r,
                  height: 13.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2.w),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
