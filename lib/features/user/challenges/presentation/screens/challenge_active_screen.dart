import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_app_bar.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_header_info.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_hero_section.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_options_sheet.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_previous_achievements.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_progress_content.dart';

// ─── Challenge Type ───────────────────────────────────────────────────────────

/// Which body the active-challenge screen shows.
///
/// Derived from the challenge's own metric rather than passed in by whoever
/// opens the screen — the server decides what a challenge measures, and a
/// caller guessing it would put a step counter on a hydration challenge.
enum ChallengeType {
  /// Steps — a counter and a ring.
  steps,

  /// Distance or calories — both come from walking and running.
  exercise,

  /// Water, in millilitres.
  hydration;

  static ChallengeType fromMetric(ChallengeMetric? metric) => switch (metric) {
        ChallengeMetric.steps => ChallengeType.steps,
        ChallengeMetric.waterMl => ChallengeType.hydration,
        // Distance and calories are both earned by moving, and an unknown
        // metric is safest here too: the generic body shows progress against
        // the goal without claiming to know how it is earned.
        _ => ChallengeType.exercise,
      };
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ChallengeActiveScreen extends StatefulWidget {
  final ChallengeModel challenge;

  const ChallengeActiveScreen({super.key, required this.challenge});

  ChallengeType get challengeType =>
      ChallengeType.fromMetric(challenge.metric);

  @override
  State<ChallengeActiveScreen> createState() => _ChallengeActiveScreenState();
}

class _ChallengeActiveScreenState extends State<ChallengeActiveScreen> {
  void _showOptionsSheet(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.black.withValues(alpha: 0.25),
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 24.h),
        backgroundColor: Colors.transparent,
        child: const ChallengeOptionsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ChallengeAppBar(
                title: 'challenges.details_title'.tr(),
                trailing: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showOptionsSheet(context),
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(Icons.more_vert_rounded, size: 22.sp, color: AppColors.black),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ChallengeHeroSection(imageUrl: widget.challenge.image),
                      SizedBox(height: 24.h),
                      ChallengeHeaderInfo(challenge: widget.challenge),
                      SizedBox(height: 24.h),
                      // One ring for every metric. It reads progress, goal and
                      // unit off the challenge, so steps, kilometres, calories
                      // and millilitres all render correctly — the old split
                      // put a mocked "today's exercise" card, with a fixed day
                      // number, on anything that was not a step challenge.
                      ChallengeProgressContent(challenge: widget.challenge),
                      SizedBox(height: 32.h),
                      const ChallengePreviousAchievements(),
                      SizedBox(height: 32.h),
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
