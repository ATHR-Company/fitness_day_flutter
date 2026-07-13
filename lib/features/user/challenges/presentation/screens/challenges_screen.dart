import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/challenges/domain/entities/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/dialogs/challenge_details_dialog.dart';
import 'package:fitness_day/features/user/challenges/presentation/screens/create_challenge_screen.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/active_challenge_card.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/add_challenge_button.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/suggested_challenge_card.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────

const _mockActiveChallenges = <ChallengeModel>[
  ChallengeModel(
    title: 'تحدي يوم الرشاقة',
    goal: '15000 خطوة خلال يوم',
    startDate: '22/2/2026',
    endDate: '23/2/2026',
    participants: 1234,
    isActive: true,
  ),
];

const _mockSuggestedChallenges = <ChallengeModel>[
  ChallengeModel(
    title: 'انقاص الوزن',
    goal: 'انقاص 2 كيلو في اسبوع',
    startDate: '21/2/2026',
    endDate: '28/2/2026',
    participants: 100,
  ),
  ChallengeModel(
    title: 'انقاص الوزن',
    goal: 'انقاص 2 كيلو في اسبوع',
    startDate: '21/2/2026',
    endDate: '28/2/2026',
    participants: 100,
  ),
  ChallengeModel(
    title: 'انقاص الوزن',
    goal: 'انقاص 2 كيلو في اسبوع',
    startDate: '21/2/2026',
    endDate: '28/2/2026',
    participants: 100,
  ),
  ChallengeModel(
    title: 'انقاص الوزن',
    goal: 'انقاص 2 كيلو في اسبوع',
    startDate: '21/2/2026',
    endDate: '28/2/2026',
    participants: 100,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final bool _hasActiveChallenges = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: _hasActiveChallenges ? _buildWithChallenges() : _buildEmptyState(),
        ),
      ),
    );
  }

  void _openCreateChallenge() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateChallengeScreen()),
    );
  }

  void _openChallengeDetails(ChallengeModel challenge) {
    showDialog(
      context: context,
      builder: (_) => ChallengeDetailsDialog(challenge: challenge),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const _ChallengesAppBar(),
        SizedBox(height: 30.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: AddChallengeButton(onTap: _openCreateChallenge),
        ),
        SizedBox(height: 80.h),
        AppImage(
          AppImages.challenge_cap,
          width: 200.w,
          height: 170.w,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 28.h),
        Text(
          'challenges.no_active_title'.tr(),
          style: TextStyleManager.heading3.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'challenges.no_active_desc'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.sideBarText.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWithChallenges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ChallengesAppBar(),
        SizedBox(height: 16.h),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_mockActiveChallenges.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: ActiveChallengeCard(
                      challenge: _mockActiveChallenges.first,
                      onTap: () => _openChallengeDetails(_mockActiveChallenges.first),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: AddChallengeButton(onTap: _openCreateChallenge),
                ),
                SizedBox(height: 28.h),
                const _SuggestedSectionHeader(),
                SizedBox(height: 16.h),
                ..._mockSuggestedChallenges.map(
                  (challenge) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                    child: SuggestedChallengeCard(
                      challenge: challenge,
                      onTap: () => _openChallengeDetails(challenge),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _ChallengesAppBar extends StatelessWidget {
  const _ChallengesAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 20.sp,
              color: AppColors.black,
            ),
          ),
          const Spacer(),
          Text(
            'challenges.screen_title'.tr(),
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          const Spacer(),
          SizedBox(width: 50.sp),
        ],
      ),
    );
  }
}

// ─── Suggested Section Header ─────────────────────────────────────────────────

class _SuggestedSectionHeader extends StatelessWidget {
  const _SuggestedSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'challenges.suggested_title'.tr(),
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 7.h),
          Row(
            children: [
              AppImage(
                SvgIcons.muscle,
                width: 16.w,
                height: 16.w,
                color: AppColors.black,
              ),
              SizedBox(width: 4.w),
              Text(
                'challenges.suggested_subtitle'.tr(),
                style: TextStyleManager.style9Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
