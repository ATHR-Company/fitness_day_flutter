import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/rewards/data/models/points_reward_models.dart';
import 'package:fitness_day/features/user/rewards/presentation/widgets/award_progress_bar.dart';

/// One entry of the rewards catalog.
///
/// Everything shown is taken from the server: the cost, the already-clamped
/// progress, how many points are still missing, and whether the button works.
class RewardCard extends StatelessWidget {
  final PointsRewardModel reward;
  final bool isRedeeming;
  final VoidCallback? onRedeem;

  const RewardCard({
    super.key,
    required this.reward,
    this.isRedeeming = false,
    this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.dividerLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top row: percent ←→ points + fire ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLeadingChild(context),
              _buildTrailingChild(context),
            ],
          ),

          SizedBox(height: 6.h),

          // ── Name / description — always on the leading edge ───────────
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              reward.description?.isNotEmpty == true
                  ? reward.description!
                  : reward.name,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // "باقي N نقطة" — only while the reward is still out of reach.
          if (!reward.canRedeem && reward.remainingPoints > 0) ...[
            SizedBox(height: 4.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'awards.remaining_points'.tr(
                  args: ['${reward.remainingPoints}'],
                ),
                style: TextStyleManager.style10Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],

          SizedBox(height: 14.h),

          // Progress comes pre-clamped to 0..100 from the backend.
          AwardProgressBar(progress: reward.progressPercentage / 100),

          SizedBox(height: 14.h),

          _RedeemButton(
            enabled: reward.canRedeem && !isRedeeming,
            isLoading: isRedeeming,
            onTap: onRedeem,
          ),
        ],
      ),
    );
  }

  /// In both directions the design shows the percentage on the visual left and
  /// the points on the visual right, which flips which one is the leading child.
  Widget _buildLeadingChild(BuildContext context) {
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    return isRtl ? _buildPointsRow() : _buildPercentLabel();
  }

  Widget _buildTrailingChild(BuildContext context) {
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    return isRtl ? _buildPercentLabel() : _buildPointsRow();
  }

  Widget _buildPercentLabel() {
    return Text(
      '${reward.progressPercentage}%',
      style: TextStyleManager.style13Medium.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildPointsRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${reward.pointsCost} ${'awards.points_unit'.tr()}',
          style: TextStyleManager.style14Bold.copyWith(
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          width: 32.r,
          height: 32.r,
          decoration: const BoxDecoration(
            color: AppColors.backgroundTint,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AppImage(SvgIcons.awardGreenFire, width: 18.r, height: 18.r),
          ),
        ),
      ],
    );
  }
}

class _RedeemButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onTap;

  const _RedeemButton({
    required this.enabled,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 46.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.inactiveGray,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.r,
                height: 22.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(
                'awards.get_discount'.tr(),
                style: TextStyleManager.button.copyWith(
                  color: enabled ? AppColors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
