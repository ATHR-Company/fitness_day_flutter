import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/errors/app_error.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// The blocking form of an error — a popup the user has to dismiss.
///
/// Reserved for failures the user must register before carrying on: a payment
/// that did not go through, an order that was refused, an account action that
/// failed. Everything else is a snackbar; see `showAppError`.
///
/// Prefer calling `showAppError(context, error, display: ErrorDisplay.dialog)`
/// over building this directly — that keeps the choice of presentation in one
/// place and readable at the call site.
class AppErrorDialog extends StatelessWidget {
  final AppError? error;
  final String? message;
  final String? title;

  /// Shown as a second button when the action is worth offering again. The
  /// dialog closes before it runs, so the caller never has to pop it.
  final VoidCallback? onRetry;

  const AppErrorDialog({
    super.key,
    this.error,
    this.message,
    this.title,
    this.onRetry,
  });

  bool get _isNetwork => error?.type == AppErrorType.network;

  String get _text {
    final String? text = error?.message ?? message;
    if (_isNetwork) return 'errors.no_internet_subtitle'.tr();
    if (text != null && text.trim().isNotEmpty) return text;
    return 'errors.generic_subtitle'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isNetwork
                    ? Icons.wifi_off_rounded
                    : Icons.error_outline_rounded,
                size: 36.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title ??
                  (_isNetwork
                      ? 'errors.no_internet_title'.tr()
                      : 'errors.something_went_wrong'.tr()),
              textAlign: TextAlign.center,
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              _text,
              textAlign: TextAlign.center,
              style: TextStyleManager.heading3.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                if (onRetry != null) ...[
                  Expanded(
                    child: _DialogButton(
                      label: 'errors.retry'.tr(),
                      filled: false,
                      onTap: () {
                        // Closed first so the retry runs against the screen
                        // underneath, not against a dialog that is going away.
                        Navigator.of(context).pop();
                        onRetry!();
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: _DialogButton(
                    label: 'errors.ok'.tr(),
                    filled: true,
                    onTap: () => Navigator.of(context).pop(),
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

class _DialogButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: filled ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyleManager.button.copyWith(
            color: filled ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
