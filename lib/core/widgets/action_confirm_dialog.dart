import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Confirmation dialog with the app's badge-and-warning look: a close button,
/// a circular icon badge, the question, an optional warning line, then a
/// filled confirm and an outlined back button.
///
/// Pops `true` when confirmed and `false` when dismissed, so callers can just
/// await it:
///
/// ```dart
/// final confirmed = await ActionConfirmDialog.show(
///   context,
///   icon: Icons.delete_outline,
///   title: 'market.delete_address_title'.tr(),
///   confirmText: 'market.delete_button'.tr(),
///   cancelText: 'market.cancel_sub_back'.tr(),
/// );
/// ```
class ActionConfirmDialog extends StatelessWidget {
  final IconData icon;
  final String title;

  /// Optional red-flagged line under the title, for the consequence the user
  /// should not miss.
  final String? warning;

  final String confirmText;
  final String cancelText;

  /// Drives the badge and the confirm button. Defaults to the brand green so
  /// every confirmation in the app reads the same.
  final Color accentColor;

  /// Runs after the dialog closes on confirm. Callers that `await` the result
  /// can ignore this and act on the returned `true` instead.
  final VoidCallback? onConfirm;

  const ActionConfirmDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.confirmText,
    required this.cancelText,
    this.warning,
    this.accentColor = AppColors.primary,
    this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String confirmText,
    required String cancelText,
    String? warning,
    Color accentColor = AppColors.error,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ActionConfirmDialog(
        icon: icon,
        title: title,
        confirmText: confirmText,
        cancelText: cancelText,
        warning: warning,
        accentColor: accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Icon(Icons.close, color: accentColor, size: 24.sp),
              ),
            ),
            SizedBox(height: 16.h),

            _IconBadge(icon: icon, accentColor: accentColor),
            SizedBox(height: 24.h),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyleManager.style13Medium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                height: 1.5,
              ),
            ),

            if (warning != null) ...[
              SizedBox(height: 16.h),
              _WarningLine(text: warning!),
            ],

            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
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
                      ),
                      child: Text(
                        confirmText,
                        style: TextStyleManager.style13Medium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: TextStyleManager.style13Medium.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Solid accent circle inside a tinted halo.
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color accentColor;

  const _IconBadge({required this.icon, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      height: 90.w,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.white, size: 28.sp),
        ),
      ),
    );
  }
}

class _WarningLine extends StatelessWidget {
  final String text;

  const _WarningLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyleManager.style9Medium.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
