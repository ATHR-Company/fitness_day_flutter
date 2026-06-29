import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';

class AppToggleSwitch extends StatefulWidget {
  const AppToggleSwitch({super.key});

  @override
  State<AppToggleSwitch> createState() => _AppToggleSwitchState();
}

class _AppToggleSwitchState extends State<AppToggleSwitch> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isOnline = !isOnline;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 44.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: isOnline
              ? AppColors.primary
              : AppColors.textSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(2.r),
        alignment: isOnline
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.centerEnd,
        child: Container(
          width: 20.w,
          height: 20.h,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
