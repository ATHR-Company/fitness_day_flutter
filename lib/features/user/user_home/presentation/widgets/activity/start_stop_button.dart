import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Start / Stop Button (Running only)
// ─────────────────────────────────────────────────────────────────────────────

class StartStopButton extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onTap;

  const StartStopButton(
      {super.key, required this.isRunning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRunning ? Colors.red.shade400 : AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: (isRunning ? Colors.red : AppColors.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 36.sp,
        ),
      ),
    );
  }
}
