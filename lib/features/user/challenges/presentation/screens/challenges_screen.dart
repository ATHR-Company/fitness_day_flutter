import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/dialogs/challenge_details_dialog.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/challenges_cubit.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/challenges_events.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/challenges_state.dart';
import 'package:fitness_day/features/user/challenges/presentation/screens/challenge_active_screen.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/active_challenge_card.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/suggested_challenge_card.dart';

/// The challenges screen: what the user has joined, and what they could join.
///
/// One request covers both sections. Asking for no `status` returns everything
/// not finished yet — active plus upcoming — and every card states whether this
/// user has joined it, so the split is local rather than a second call.
class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChallengesCubit>()..load(),
      child: const _ChallengesView(),
    );
  }
}

class _ChallengesView extends StatefulWidget {
  const _ChallengesView();

  @override
  State<_ChallengesView> createState() => _ChallengesViewState();
}

class _ChallengesViewState extends State<_ChallengesView> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<AppEvent>? _ledgerSub;

  /// How close to the bottom before the next page starts loading.
  static const double _loadMoreThreshold = 300;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // A sync from anywhere in the app carries every live challenge with it, so
    // the rings here move without this screen asking again.
    _ledgerSub = getIt<AppEventBus>().stream.listen((event) {
      if (event is! ActivityLedgerChanged || !mounted) return;
      context.read<ChallengesCubit>().applyLedgerUpdate(event.challenges);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      // The cubit ignores this when there is no next page or one is already in
      // flight, so firing it on every tick is fine.
      context.read<ChallengesCubit>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _ledgerSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openDetails(ChallengeModel challenge) async {
    final cubit = context.read<ChallengesCubit>();

    // Already in it — go straight to the challenge. The details sheet exists to
    // decide whether to join; re-asking someone who has already joined only put
    // "Leave" in front of them, with no way through to their own progress.
    if (challenge.isJoined) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChallengeActiveScreen(challenge: challenge),
        ),
      );
      // They may have left from the overflow menu, which moves the card.
      if (mounted) cubit.load();
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => ChallengeDetailsDialog(challenge: challenge),
    );
    // The sheet can join, and that moves a card between sections.
    if (mounted) cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              const _ChallengesAppBar(),
              Expanded(
                child: BlocBuilder<ChallengesCubit, ChallengesState>(
                  builder: (context, state) => switch (state) {
                    ChallengesError(:final message, :final error) =>
                      AppErrorView(
                        error: error,
                        message: message,
                        onRetry: () => context.read<ChallengesCubit>().load(),
                      ),
                    ChallengesLoaded() => _buildList(context, state),
                    _ => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, ChallengesLoaded state) {
    final joined = state.challenges.where((c) => c.isJoined).toList();
    final suggested = state.challenges.where((c) => !c.isJoined).toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<ChallengesCubit>().load(),
      child: state.challenges.isEmpty
          ? _buildEmptyState()
          : ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
              children: [
                for (final challenge in joined)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                    child: ActiveChallengeCard(
                      challenge: challenge,
                      onTap: () => _openDetails(challenge),
                    ),
                  ),
                if (suggested.isNotEmpty) ...[
                  SizedBox(height: joined.isEmpty ? 0 : 12.h),
                  const _SuggestedSectionHeader(),
                  SizedBox(height: 16.h),
                  for (final challenge in suggested)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                      child: SuggestedChallengeCard(
                        challenge: challenge,
                        onTap: () => _openDetails(challenge),
                      ),
                    ),
                ],
                if (state.isLoadingMore)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  /// Scrollable so pull-to-refresh keeps working with nothing on screen.
  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
          ),
        ),
      ),
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
