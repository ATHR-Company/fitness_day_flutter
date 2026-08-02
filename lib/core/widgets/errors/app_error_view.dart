import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/errors/app_error.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// The one full-screen failure state in the app.
///
/// Use it when the screen has **no content to show** — a first load that
/// failed. If the screen already has data on it, an error is a message, not a
/// takeover: use `showAppError` instead so the user keeps what they were
/// reading.
///
/// ```dart
/// if (state is XFailure) {
///   return AppErrorView(
///     error: state.error,
///     message: state.message,
///     onRetry: () => context.read<XCubit>().load(),
///   );
/// }
/// ```
///
/// The look follows [AppError.type]: a connection failure gets the offline
/// artwork and a Retry button and says nothing about causes, because there is
/// nothing to say. A server failure shows the backend's own message, which is
/// usually the actionable part.
class AppErrorView extends StatelessWidget {
  /// Null is treated as a server error — the safe default, since it shows the
  /// message instead of hiding it behind a Retry button.
  final AppError? error;

  /// Fallback for states that have not been migrated to carry an [AppError].
  final String? message;

  final VoidCallback? onRetry;

  /// Overrides the heading. Rarely needed — the type picks a sensible one.
  final String? title;

  const AppErrorView({
    super.key,
    this.error,
    this.message,
    this.onRetry,
    this.title,
  });

  bool get _isNetwork => error?.type == AppErrorType.network;

  @override
  Widget build(BuildContext context) {
    // Scrollable so it still works as a RefreshIndicator child — pull-to-refresh
    // has to keep working on a screen that failed to load.
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.r,
              height: 96.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isNetwork
                    ? Icons.wifi_off_rounded
                    : Icons.error_outline_rounded,
                size: 44.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              title ?? _title,
              textAlign: TextAlign.center,
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: TextStyleManager.heading3.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 28.h),
              _RetryButton(onTap: onRetry!),
            ],
          ],
        ),
      ),
    );
  }

  String get _title => _isNetwork
      ? 'errors.no_internet_title'.tr()
      : 'errors.something_went_wrong'.tr();

  /// A connection failure's message is a fixed internal string, so the
  /// localized copy reads better than passing it through. A server failure's
  /// message is the whole point, so it wins over any default.
  String get _subtitle {
    if (_isNetwork) return 'errors.no_internet_subtitle'.tr();
    final String? text = error?.message ?? message;
    if (text != null && text.trim().isNotEmpty) return text;
    return 'errors.generic_subtitle'.tr();
  }
}

class _RetryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RetryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, color: AppColors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'errors.retry'.tr(),
              style: TextStyleManager.button.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
