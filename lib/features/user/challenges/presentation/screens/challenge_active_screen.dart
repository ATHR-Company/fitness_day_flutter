import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/challenges/domain/entities/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_app_bar.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_exercise_content.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_header_info.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_hero_section.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_options_sheet.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_previous_achievements.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_steps_content.dart';

// ─── Challenge Type ───────────────────────────────────────────────────────────

enum ChallengeType { steps, exercise }

// ─── Screen ───────────────────────────────────────────────────────────────────

class ChallengeActiveScreen extends StatefulWidget {
  final ChallengeModel challenge;
  final ChallengeType challengeType;

  const ChallengeActiveScreen({
    super.key,
    required this.challenge,
    this.challengeType = ChallengeType.exercise,
  });

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
                      ChallengeHeroSection(imageUrl: widget.challenge.imageUrl),
                      SizedBox(height: 24.h),
                      ChallengeHeaderInfo(challenge: widget.challenge),
                      SizedBox(height: 24.h),
                      if (widget.challengeType == ChallengeType.steps)
                        ChallengeStepsContent(challenge: widget.challenge)
                      else
                        ChallengeExerciseContent(challenge: widget.challenge),
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
