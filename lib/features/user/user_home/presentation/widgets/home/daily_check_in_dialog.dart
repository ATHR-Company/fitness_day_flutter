import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/rewards/data/models/daily_check_in_models.dart';
import 'package:fitness_day/features/user/rewards/domain/usecases/get_daily_check_in_status_usecase.dart';
import 'package:fitness_day/features/user/rewards/presentation/manager/daily_check_in_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Public helpers ────────────────────────────────────────────────────────────

/// Asks the backend whether today's reward is still unclaimed.
///
/// The cycle rolls over at 00:00 **UTC**, and the server recomputes the streak
/// on every request — so this is never derived from a stored date on the
/// device. A failure (offline, or a profile that isn't finished yet, which the
/// backend rejects with `403`) simply means "don't pop the dialog": an
/// auto-opening popup must never surface an error the user didn't ask for.
Future<bool> shouldShowDailyCheckIn() async {
  final result = await getIt<GetDailyCheckInStatusUseCase>()();
  return switch (result) {
    Success(:final data) => data.canClaimToday,
    FailureResult() => false,
  };
}

/// Shows the daily check-in dialog. Safe to call from `addPostFrameCallback`.
Future<void> showDailyCheckInDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => BlocProvider(
      create: (_) => getIt<DailyCheckInCubit>()..loadStatus(),
      child: const _DailyCheckInDialog(),
    ),
  );
}

// ── Dialog widget ─────────────────────────────────────────────────────────────

class _DailyCheckInDialog extends StatelessWidget {
  const _DailyCheckInDialog();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DailyCheckInCubit, DailyCheckInState>(
      listener: (context, state) {
        if (state is! DailyCheckInLoaded) return;

        // Always the backend's own message — it arrives already translated to
        // the `lang` that was sent, so nothing is worded here.
        final String? message = state.message;
        if (message != null) {
          showAppSnackBar(context, text: message, isError: state.messageIsError);
          context.read<DailyCheckInCubit>().consumeAward();
          return;
        }

        final int? awarded = state.justAwardedPoints;
        if (awarded != null) {
          showAppSnackBar(
            context,
            text: 'check_in.claimed_points'.tr(args: ['$awarded']),
            isSuccess: true,
          );
          context.read<DailyCheckInCubit>().consumeAward();
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: AppColors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            child: switch (state) {
              DailyCheckInLoaded() => _CycleContent(state: state),
              DailyCheckInFailure(:final message) => _MessageBody(
                  message: message,
                  onClose: () => Navigator.of(context).pop(),
                ),
              _ => SizedBox(
                  height: 160.h,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            },
          ),
        );
      },
    );
  }
}

/// Error / empty body — shows whatever the backend said and nothing else.
class _MessageBody extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const _MessageBody({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyleManager.style13Medium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        TextButton(
          onPressed: onClose,
          child: Text(
            'check_in.close'.tr(),
            style: TextStyleManager.button.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

/// The cycle itself. Everything here is driven by `days[]` — the number of
/// cards and the points on each are server-owned and change from the dashboard
/// without an app release.
class _CycleContent extends StatelessWidget {
  final DailyCheckInLoaded state;

  const _CycleContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final DailyCheckInStatusModel status = state.status;
    final List<CheckInDayModel> days = status.days;

    // The design lays the cycle out three-per-row with the final day given a
    // full-width row of its own. Built from the list length, not from a
    // hardcoded seven, so a shorter or longer cycle still renders.
    final List<CheckInDayModel> gridDays =
        days.length > 1 ? days.sublist(0, days.length - 1) : const [];
    final CheckInDayModel? lastDay = days.isNotEmpty ? days.last : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Title row ─────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: SizedBox(
                width: 32.r,
                height: 32.r,
                child: Icon(
                  Icons.close_rounded,
                  size: 20.sp,
                  color: AppColors.black,
                ),
              ),
            ),
            Text(
              'check_in.title'.tr(),
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
              ),
            ),
            // Invisible spacer keeps title centred
            SizedBox(width: 32.r),
          ],
        ),

        SizedBox(height: 12.h),

        // ── Points balance ────────────────────────────────────────────
        Text(
          'check_in.your_points'.tr(args: ['${status.pointsBalance}']),
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        SizedBox(height: 12.h),

        // ── Day grid ──────────────────────────────────────────────────
        for (int start = 0; start < gridDays.length; start += 3) ...[
          _DayRow(
            days: gridDays.sublist(
              start,
              (start + 3) > gridDays.length ? gridDays.length : start + 3,
            ),
          ),
          SizedBox(height: 10.h),
        ],
        if (lastDay != null)
          _DayTile(day: lastDay, isSpecial: true),

        SizedBox(height: 24.h),

        // ── Claim button ──────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.inactiveGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            onPressed: (!status.canClaimToday || state.isClaiming)
                ? null
                : () => context.read<DailyCheckInCubit>().claim(),
            child: state.isClaiming
                ? SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    status.canClaimToday
                        ? '${'check_in.claim_button'.tr()}  +${status.todayPoints}'
                        : 'check_in.already_claimed'.tr(),
                    style: TextStyleManager.button.copyWith(
                      color: status.canClaimToday
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final List<CheckInDayModel> days;

  const _DayRow({required this.days});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _DayTile(day: day),
            ),
          ),
        // Keeps a short final row aligned with the rows above it.
        for (int i = days.length; i < 3; i++) const Expanded(child: SizedBox()),
      ],
    );
  }
}

// ── Day Tile ──────────────────────────────────────────────────────────────────

class _DayTile extends StatelessWidget {
  final CheckInDayModel day;
  final bool isSpecial;

  const _DayTile({required this.day, this.isSpecial = false});

  @override
  Widget build(BuildContext context) {
    // Only the three states the backend defines are rendered; anything else it
    // may add later falls through to the locked look rather than inventing a
    // fourth appearance.
    final bool isClaimed = day.state == CheckInDayState.claimed;
    final bool isToday = day.state == CheckInDayState.available;

    final Color bg = isClaimed
        ? AppColors.backgroundTint
        : isToday
            ? AppColors.white
            : isSpecial
                ? AppColors.backgroundTint
                : AppColors.greyBackground;

    final Color borderColor = isToday
        ? AppColors.primary
        : isClaimed
            ? AppColors.greenMint
            : Colors.transparent;

    final double borderWidth = (isToday || isClaimed) ? 1.5.w : 0;

    final bool highlighted = isClaimed || isToday || isSpecial;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Day label pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: highlighted
                      ? AppColors.greenMint.withValues(alpha: 0.4)
                      : AppColors.divider.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${'check_in.day'.tr()} ${day.dayNumber}',
                  style: TextStyleManager.style8Medium.copyWith(
                    color: highlighted
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              // Fire icon — solid green once claimed or today, muted otherwise
              AppImage(
                SvgIcons.awardGreenFire,
                width: 28.r,
                height: 28.r,
                color: (isClaimed || isToday)
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.4),
              ),
              SizedBox(height: 6.h),
              // Points label — forced LTR so the "+" sign doesn't get
              // flipped to the wrong side by RTL bidi reordering
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(
                  '+${day.points}',
                  style: TextStyleManager.style13Medium.copyWith(
                    color: highlighted
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Green checkmark badge for claimed days
        if (isClaimed)
          Positioned(
            top: -4.h,
            left: 6.w,
            child: Container(
              width: 18.r,
              height: 18.r,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 12.sp,
                color: AppColors.white,
              ),
            ),
          ),

        // Gift icon for the final day's reward — overlaps the leading edge,
        // vertically centered (matches reference design)
        if (isSpecial)
          Positioned(
            left: -10.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: AppImage(
                SvgIcons.awardGift,
                width: 32.r,
                height: 32.r,
              ),
            ),
          ),
      ],
    );
  }
}
