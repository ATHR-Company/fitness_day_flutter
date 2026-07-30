import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/rewards/data/models/redemption_models.dart';
import 'package:fitness_day/features/user/rewards/presentation/manager/awards_cubit.dart';
import 'package:fitness_day/features/user/rewards/presentation/pages/my_coupons_page.dart';
import 'package:fitness_day/features/user/rewards/presentation/widgets/check_in_calendar.dart';
import 'package:fitness_day/features/user/rewards/presentation/widgets/coupon_code_dialog.dart';
import 'package:fitness_day/features/user/rewards/presentation/widgets/points_pill.dart';
import 'package:fitness_day/features/user/rewards/presentation/widgets/reward_card.dart';

/// Awards page — the user's points balance, the monthly check-in grid and the
/// rewards they can buy with points.
///
/// Everything on it is server-owned: the balance, the calendar and the catalog
/// all come from the API on every open, and the point costs are edited from the
/// dashboard without an app release.
class AwardsPage extends StatelessWidget {
  const AwardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AwardsCubit>()..load(),
      child: const _AwardsView(),
    );
  }
}

class _AwardsView extends StatelessWidget {
  const _AwardsView();

  Future<void> _onRedeem(BuildContext context, String rewardId) async {
    final AwardsCubit cubit = context.read<AwardsCubit>();
    final RedemptionModel? redemption = await cubit.redeem(rewardId);
    if (!context.mounted) return;

    if (redemption != null) {
      await showCouponCodeDialog(context, redemption);
      return;
    }

    // Failed — show the backend's own message. Nothing was charged: a failed
    // redeem is rolled back server-side, so pressing again is safe.
    final String? message = cubit.lastMessage;
    if (message != null && context.mounted) {
      showAppSnackBar(context, text: message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.profileGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: AppBackHeader(title: 'profile_page.awards'.tr()),
              ),
              Expanded(
                child: BlocBuilder<AwardsCubit, AwardsState>(
                  builder: (context, state) {
                    return switch (state) {
                      AwardsLoaded() => _LoadedBody(
                          state: state,
                          onRedeem: (id) => _onRedeem(context, id),
                        ),
                      AwardsFailure(:final message) =>
                        _MessageState(message: message),
                      _ => Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final AwardsLoaded state;
  final ValueChanged<String> onRedeem;

  const _LoadedBody({required this.state, required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<AwardsCubit>().load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero banner ──────────────────────────────────────
            const _HeroBanner(),
            SizedBox(height: 12.h),

            // ── Current points pill ──────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: PointsPill(points: state.pointsBalance),
            ),
            SizedBox(height: 12.h),

            // ── My coupons ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const _MyCouponsTile(),
            ),
            SizedBox(height: 20.h),

            // ── Activity calendar ────────────────────────────────
            if (state.calendar != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CheckInCalendar(
                  calendar: state.calendar!,
                  onMonthChanged: (delta) =>
                      context.read<AwardsCubit>().changeMonth(delta),
                ),
              ),
            SizedBox(height: 20.h),

            // ── Reward cards ─────────────────────────────────────
            if (state.rewards.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Text(
                  'awards.no_rewards'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style12Regular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...state.rewards.map(
                (reward) => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: RewardCard(
                    reward: reward,
                    isRedeeming: state.redeemingRewardId == reward.id,
                    onRedeem: () => onRedeem(reward.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero Banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.hardEdge,
      // Trophy / gifts illustration — always centred
      child: Image.asset(
        AppImages.award1,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ─── My coupons entry ─────────────────────────────────────────────────────────

class _MyCouponsTile extends StatelessWidget {
  const _MyCouponsTile();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MyCouponsPage()),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundTint,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.confirmation_number_outlined,
                color: AppColors.primary, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'awards.my_coupons'.tr(),
                style: TextStyleManager.style13Medium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: AppColors.textSecondary, size: 14.sp),
          ],
        ),
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class _MessageState extends StatelessWidget {
  final String message;

  const _MessageState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.primary, size: 44.sp),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyleManager.style11Medium,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context.read<AwardsCubit>().load(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: Text('awards.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
