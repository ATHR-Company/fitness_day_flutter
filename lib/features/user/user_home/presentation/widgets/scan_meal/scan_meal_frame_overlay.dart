import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';

/// Viewfinder drawn over the live preview: four corner brackets marking where
/// to place the plate.
///
/// The alignment hint lives below the preview now ([ScanMealHint]) — inside
/// here it sat under the shutter button.
class ScanMealFrameOverlay extends StatelessWidget {
  const ScanMealFrameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Inset from the card edges rather than the old full-height values, which
      // were sized for a preview that filled the whole page.
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 32.h),
      child: const Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: _FrameCorner(isTop: true, isLeft: true),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _FrameCorner(isTop: true, isLeft: false),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _FrameCorner(isTop: false, isLeft: true),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _FrameCorner(isTop: false, isLeft: false),
          ),
        ],
      ),
    );
  }
}

/// One right-angle bracket. [isTop] / [isLeft] pick which two edges are drawn,
/// so the same widget covers all four corners.
class _FrameCorner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _FrameCorner({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    final BorderSide side = BorderSide(color: AppColors.white, width: 3.w);

    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? side : BorderSide.none,
          bottom: isTop ? BorderSide.none : side,
          left: isLeft ? side : BorderSide.none,
          right: isLeft ? BorderSide.none : side,
        ),
      ),
    );
  }
}
