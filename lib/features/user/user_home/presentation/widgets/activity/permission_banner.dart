import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Permission Banner
// ─────────────────────────────────────────────────────────────────────────────

class PermissionBanner extends StatelessWidget {
  final String message;
  final VoidCallback onTap;

  const PermissionBanner(
      {super.key, required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.health_and_safety_outlined,
                color: AppColors.primary, size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(message,
                  style: TextStyleManager.style11Medium
                      .copyWith(color: AppColors.black)),
            ),
            TextButton(
              onPressed: onTap,
              child: Text('activity_tracking.allow'.tr(),
                  style: TextStyleManager.style11Medium
                      .copyWith(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
