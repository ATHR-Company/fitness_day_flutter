import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/domain/entities/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/screens/challenge_active_screen.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/date_badge.dart';

class ChallengeDetailsDialog extends StatefulWidget {
  final ChallengeModel challenge;
  final ChallengeType challengeType;

  const ChallengeDetailsDialog({
    super.key,
    required this.challenge,
    this.challengeType = ChallengeType.steps,
  });

  @override
  State<ChallengeDetailsDialog> createState() => _ChallengeDetailsDialogState();
}

class _ChallengeDetailsDialogState extends State<ChallengeDetailsDialog> {
  bool _isDescriptionSelected = true;

  void _goToRules() => setState(() => _isDescriptionSelected = false);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        height: 650.h,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            children: [
              _DialogHeader(onClose: () => Navigator.pop(context)),
              _ImageWithTabSwitcher(
                imageUrl: widget.challenge.imageUrl,
                isDescriptionSelected: _isDescriptionSelected,
                onTabChanged: (val) => setState(() => _isDescriptionSelected = val),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _isDescriptionSelected
                      ? _DescriptionTab(
                          challenge: widget.challenge,
                          onNext: _goToRules,
                        )
                      : _RulesTab(
                          challenge: widget.challenge,
                          challengeType: widget.challengeType,
                        ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dialog Header ────────────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _DialogHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4EA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close_rounded, color: AppColors.primary, size: 30.sp),
          ),
          const Spacer(),
          Text(
            'challenges.details_title'.tr(),
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          SizedBox(width: 28.sp),
        ],
      ),
    );
  }
}

// ─── Image with Tab Switcher ─────────────────────────────────────────────────

class _ImageWithTabSwitcher extends StatelessWidget {
  final String? imageUrl;
  final bool isDescriptionSelected;
  final ValueChanged<bool> onTabChanged;

  static const _fallbackUrl =
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400';

  const _ImageWithTabSwitcher({
    this.imageUrl,
    required this.isDescriptionSelected,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Image.network(
          imageUrl ?? _fallbackUrl,
          height: 180.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: -24.h,
          child: _TabSwitcher(
            isDescriptionSelected: isDescriptionSelected,
            onTabChanged: onTabChanged,
          ),
        ),
      ],
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final bool isDescriptionSelected;
  final ValueChanged<bool> onTabChanged;

  const _TabSwitcher({
    required this.isDescriptionSelected,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.primary, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'challenges.tab_description'.tr(),
            isSelected: isDescriptionSelected,
            onTap: () => onTabChanged(true),
          ),
          _TabItem(
            label: 'challenges.tab_rules'.tr(),
            isSelected: !isDescriptionSelected,
            onTap: () => onTabChanged(false),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE6F4EA) : Colors.transparent,
            borderRadius: BorderRadius.circular(24.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyleManager.style11Medium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Description Tab ──────────────────────────────────────────────────────────

class _DescriptionTab extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback onNext;

  const _DescriptionTab({required this.challenge, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40.h),
        Container(
          width: 56.w,
          height: 56.w,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Center(
            child: Image.asset(AppImages.challenge_cap, width: 40.w, height: 40.w),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          '${'challenges.goal_prefix'.tr()}${challenge.goal}',
          style: TextStyleManager.style10Medium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DateBadge(label: challenge.endDate, isEnd: true),
            SizedBox(width: 32.w),
            DateBadge(label: challenge.startDate, isEnd: false),
          ],
        ),
        SizedBox(height: 24.h),
        Text(
          'challenges.description_label'.tr(),
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'challenges.description_body'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.style10Medium.copyWith(
              color: AppColors.textSecondary,
              // height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 32.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
              elevation: 0,
            ),
            child: Text(
              'challenges.btn_next'.tr(),
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Rules Tab ────────────────────────────────────────────────────────────────

class _RulesTab extends StatelessWidget {
  final ChallengeModel challenge;
  final ChallengeType challengeType;

  static const _ruleKeys = [
    'challenges.rule_1',
    'challenges.rule_2',
    'challenges.rule_3',
    'challenges.rule_4',
    'challenges.rule_5',
  ];

  const _RulesTab({required this.challenge, required this.challengeType});

  void _onJoin(BuildContext context) {
    Navigator.pop(context); // close dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeActiveScreen(
          challenge: challenge,
          challengeType: challengeType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32.h),
        ..._ruleKeys.map((key) => _RuleItem(text: key.tr())),
        SizedBox(height: 32.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ElevatedButton(
            onPressed: () => _onJoin(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
              elevation: 0,
            ),
            child: Text(
              'challenges.btn_join'.tr(),
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String text;

  const _RuleItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(Icons.radio_button_checked, color: AppColors.primary, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textPrimary,
                // height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
