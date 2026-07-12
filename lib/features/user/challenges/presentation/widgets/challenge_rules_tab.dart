import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/domain/entities/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/screens/challenge_active_screen.dart';

/// "Rules" tab content of the challenge details dialog, ending with the
/// join-challenge action.
class ChallengeRulesTab extends StatelessWidget {
  final ChallengeModel challenge;
  final ChallengeType challengeType;

  static const _ruleKeys = [
    'challenges.rule_1',
    'challenges.rule_2',
    'challenges.rule_3',
    'challenges.rule_4',
    'challenges.rule_5',
  ];

  const ChallengeRulesTab({super.key, required this.challenge, required this.challengeType});

  void _onJoin(BuildContext context) {
    Navigator.pop(context); // close dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeActiveScreen(challenge: challenge, challengeType: challengeType),
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
