import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter_svg/svg.dart';

/// Generic destructive/critical-action confirmation dialog: an accent-colored
/// icon badge, title, subtitle, and Cancel/Confirm buttons. Pops with `true`
/// when confirmed, `false` (or nothing) when dismissed/cancelled.
///
/// [ExitDialog] is a pre-configured instance of this; build others (e.g. a
/// delete-account confirmation) the same way rather than duplicating the
/// dialog chrome.
class ConfirmDialog extends StatelessWidget {
  final IconData? icon;
  final String? svgIcon;
  final String title;
  final String subtitle;
  final String confirmText;
  final String cancelText;
  final Color accentColor;
  final VoidCallback? onConfirm;

  const ConfirmDialog({
    super.key,
    this.icon,
    this.svgIcon,
    required this.title,
    required this.subtitle,
    required this.confirmText,
    required this.cancelText,
    this.accentColor = AppColors.error,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      // Scrollable: the icon badge, title, subtitle and buttons are close to
      // the screen height already, and every text here grows with the device's
      // font-size setting.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Icon(Icons.close, color: accentColor, size: 24.sp),
                  ),
                ],
              ),
            ),

            // Icon in the middle — accent-colored badge
            SizedBox(height: 32.h),
            svgIcon != null
                ? SvgPicture.asset(svgIcon!, width: 100.w, height: 100.h)
                : Container(
                    width: 100.r,
                    height: 100.r,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor, width: 2),
                    ),
                    child: Icon(icon, size: 40.sp, color: accentColor),
                  ),
            SizedBox(height: 24.h),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyleManager.heading2.copyWith(
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(
                          color: AppColors.textSecondary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      // Half-width slots: "Leave challenge" / "احذف الحساب" have
                      // to shrink rather than wrap or clip.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          cancelText,
                          maxLines: 1,
                          style: TextStyleManager.style14Bold.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                        onConfirm?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          confirmText,
                          maxLines: 1,
                          style: TextStyleManager.style14Bold.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
