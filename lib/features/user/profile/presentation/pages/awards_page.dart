import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

/// Awards page — shows the user's current points, a monthly activity calendar,
/// a referral banner, and redeemable award cards.
///
/// Fully direction-aware: Arabic (RTL) mirrors the layout automatically via
/// Directionality-sensitive widgets (Row, AlignmentDirectional, etc.).
/// All hardcoded left/right positioning uses [_isRtl] helpers or
/// [AlignmentDirectional] / [EdgeInsetsDirectional] instead.
class AwardsPage extends StatelessWidget {
  const AwardsPage({super.key});

  // ── Mock data ──────────────────────────────────────────────────────────────
  static const int _currentPoints = 367;

  /// Days the user was active this month (1-indexed).
  static const Set<int> _activeDays = {9, 10, 11, 12, 13, 14, 15, 16};

  /// Days the user missed this month (1-indexed).
  static const Set<int> _missedDays = {1, 2, 3, 4, 5, 6, 7, 8};

  static const List<_AwardItem> _awards = [
    _AwardItem(
      points: 500,
      percentLabel: '65%',
      progress: 0.65,
      descriptionKey: 'awards.award_desc_500',
    ),
    _AwardItem(
      points: 1000,
      percentLabel: '30%',
      progress: 0.30,
      descriptionKey: 'awards.award_desc_1000',
    ),
  ];

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
                child: SingleChildScrollView(
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
                        child: _PointsPill(points: _currentPoints),
                      ),
                      SizedBox(height: 20.h),

                      // ── Activity calendar ────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _ActivityCalendar(
                          activeDays: _activeDays,
                          missedDays: _missedDays,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // ── Referral banner ──────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: const _ReferralBanner(),
                      ),
                      SizedBox(height: 16.h),

                      // ── Award cards ──────────────────────────────────────
                      ..._awards.map(
                        (award) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          child: _AwardCard(award: award),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 180.h,
      decoration: BoxDecoration(
      
        borderRadius: BorderRadius.circular(16.r),
      
      ),
      clipBehavior: Clip.hardEdge,
      child: // Trophy / gifts illustration — always centred
      Image.asset(
        AppImages.award1,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ─── Points Pill ─────────────────────────────────────────────────────────────

class _PointsPill extends StatelessWidget {
  final int points;

  const _PointsPill({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundTint,
        borderRadius: BorderRadius.circular(12.r),
      ),
      // Row respects Directionality automatically:
      // RTL → label on right, value on left
      // LTR → label on left, value on right
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Leading side
          Text(
            'awards.your_points'.tr(),
            style: TextStyleManager.style14Medium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Trailing side: points + fire
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$points',
                style: TextStyleManager.style16Bold.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 6.w),
              AppImage(SvgIcons.awardGreenFire, width: 22.r, height: 22.r),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Activity Calendar ────────────────────────────────────────────────────────

class _ActivityCalendar extends StatelessWidget {
  final Set<int> activeDays;
  final Set<int> missedDays;

  const _ActivityCalendar({required this.activeDays, required this.missedDays});

  // LTR column order: Sat Sun Mon Tue Wed Thu Fri (index 0→6)
  static const List<String> _ltrHeaders = [
    'common.weekdays.sat',
    'common.weekdays.sun',
    'common.weekdays.mon',
    'common.weekdays.tue',
    'common.weekdays.wed',
    'common.weekdays.thu',
    'common.weekdays.fri',
  ];

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    // In RTL the visual columns run right→left: Sat is the rightmost column.
    // We keep the logical data in the same Sat-first order but let the Row
    // reverse itself by wrapping in a Directionality(ltr) so columns always
    // render Sat at index-0, then the outer RTL context mirrors the Row visually.
    //
    // July 2026: 1st falls on Wednesday → offset 4 in Sat-first grid.
    const int startOffset = 4;
    const int totalDays = 31;
    const int totalCells = startOffset + totalDays;
    final int rowCount = (totalCells / 7).ceil();

    // Build grid rows in logical (Sat-first) order.
    // The outer Directionality widget on the Column mirrors everything for RTL.
    final List<Widget> gridRows = [];
    for (int row = 0; row < rowCount; row++) {
      final List<Widget> cells = [];
      for (int col = 0; col < 7; col++) {
        final int cellIndex = row * 7 + col;
        final int day = cellIndex - startOffset + 1;

        cells.add(
          Expanded(
            child: (day < 1 || day > totalDays)
                ? const SizedBox()
                : _DayCell(
                    day: day,
                    isActive: activeDays.contains(day),
                    isMissed: missedDays.contains(day),
                  ),
          ),
        );
      }
      gridRows.add(Row(children: cells));
    }

    // Header row in same logical order
    final List<Widget> headers = _ltrHeaders
        .map(
          (key) => Expanded(
            child: Center(
              child: Text(
                key.tr(),
                style: TextStyleManager.style10Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        )
        .toList();

    // Wrap in LTR so grid internal logic is always Sat-at-col-0.
    // The outer Directionality (from app locale) will mirror the entire
    // widget visually for Arabic, making col-0 appear on the right.
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Column(
        children: [
          Row(children: headers),
          SizedBox(height: 8.h),
          ...gridRows,
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isActive;
  final bool isMissed;

  const _DayCell({
    required this.day,
    required this.isActive,
    required this.isMissed,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasIcon = isActive || isMissed;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasIcon)
            AppImage(
              isActive ? SvgIcons.awardGreenFire : SvgIcons.awardRedFire,
              width: 26.r,
              height: 26.r,
            )
          else
            SizedBox(height: 26.r),
          SizedBox(height: 2.h),
          Text(
            '$day',
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Referral Banner ─────────────────────────────────────────────────────────

class _ReferralBanner extends StatelessWidget {
  const _ReferralBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundTint,
        borderRadius: BorderRadius.circular(12.r),
      ),
      // Row is Directionality-aware: gift icon is always on the leading side,
      // text follows. RTL → icon on right; LTR → icon on left.
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Leading: gift icon
          AppImage(SvgIcons.awardGift, width: 30.r, height: 30.r),
          SizedBox(width: 12.w),
          // Text — Flexible prevents overflow
          Flexible(
            child: Text(
              'awards.share_friends'.tr(),
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Award Card ───────────────────────────────────────────────────────────────

class _AwardCard extends StatelessWidget {
  final _AwardItem award;

  const _AwardCard({required this.award});

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
          // Row respects Directionality:
          // RTL → percent on left (trailing), points+fire on right (leading)
          // LTR → percent on left (leading), points+fire on right (trailing)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // First child = leading in current direction
              _buildLeadingChild(context),
              // Second child = trailing in current direction
              _buildTrailingChild(context),
            ],
          ),

          SizedBox(height: 6.h),

          // ── Description — always aligned to the leading edge ──────────
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              award.descriptionKey.tr(),
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // ── Progress bar — fills from leading edge ────────────────────
          _AwardProgressBar(progress: award.progress),

          SizedBox(height: 14.h),

          // ── Get discount button ───────────────────────────────────────
          _GetDiscountButton(label: 'awards.get_discount'.tr()),
        ],
      ),
    );
  }

  /// In RTL: leading = percent label (appears on right visually)
  /// In LTR: leading = percent label (appears on left visually)
  Widget _buildLeadingChild(BuildContext context) {
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    // In the design both directions show percent on the left visually
    // and points+fire on the right visually — which means:
    //   LTR: percent = first child (leading = left), points = second child
    //   RTL: percent = second child (trailing = left), points = first child
    return isRtl ? _buildPointsRow() : _buildPercentLabel();
  }

  Widget _buildTrailingChild(BuildContext context) {
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    return isRtl ? _buildPercentLabel() : _buildPointsRow();
  }

  Widget _buildPercentLabel() {
    return Text(
      award.percentLabel,
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
          '${award.points} ${'awards.points_unit'.tr()}',
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

// ─── Award Progress Bar ───────────────────────────────────────────────────────

/// Direction-aware progress bar.
/// LTR: fills from left → right.
/// RTL: fills from right → left.
class _AwardProgressBar extends StatelessWidget {
  final double progress; // 0.0 – 1.0

  const _AwardProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double filled = (totalWidth * progress).clamp(0.0, totalWidth);
        // Thumb centre sits at the progressed edge
        final double thumbEdge = (filled - 6.r).clamp(0.0, totalWidth - 12.r);

        return SizedBox(
          height: 14.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Track
              Container(
                width: totalWidth,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              // Filled portion — anchored to the leading edge
              Positioned(
                left: isRtl ? null : 0,
                right: isRtl ? 0 : null,
                child: Container(
                  width: filled,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              // Thumb dot — sits at the end of the filled portion
              Positioned(
                left: isRtl ? null : thumbEdge,
                right: isRtl ? thumbEdge : null,
                child: Container(
                  width: 13.r,
                  height: 13.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2.w),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Get Discount Button ──────────────────────────────────────────────────────

class _GetDiscountButton extends StatelessWidget {
  final String label;

  const _GetDiscountButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.inactiveGray,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        label,
        style: TextStyleManager.button.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class _AwardItem {
  final int points;
  final String percentLabel;
  final double progress;
  final String descriptionKey;

  const _AwardItem({
    required this.points,
    required this.percentLabel,
    required this.progress,
    required this.descriptionKey,
  });
}
