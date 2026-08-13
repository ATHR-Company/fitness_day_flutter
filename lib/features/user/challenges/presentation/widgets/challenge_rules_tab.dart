import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';

/// "Rules" tab of the challenge details dialog, ending with the join or leave
/// action.
///
/// The rules are the server's — `GET /challenges/:id` returns them already
/// translated to the requested language. They used to be five hardcoded keys,
/// which meant every challenge showed the same five sentences no matter what it
/// actually asked of the user.
/// Scrolling content only — the action button is pinned to the bottom of the
/// sheet by [ChallengeDetailsDialog], so it sits at the same height here as it
/// does on the description tab.
class ChallengeRulesTab extends StatelessWidget {
  final ChallengeModel challenge;

  const ChallengeRulesTab({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32.h),
        if (challenge.rules.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'challenges.no_rules'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ...challenge.rules.map((rule) => _RuleItem(text: rule)),
        SizedBox(height: 24.h),
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
            child: Icon(Icons.radio_button_checked,
                color: AppColors.primary, size: 18.sp),
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
