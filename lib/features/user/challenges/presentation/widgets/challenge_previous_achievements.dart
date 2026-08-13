import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/achievements_cubit.dart';
import 'package:fitness_day/features/user/profile/presentation/pages/achievements_page.dart';

/// "Previous achievements" at the bottom of the active challenge screen — the
/// badges this user has actually earned, newest first.
///
/// Reads the badge wall and keeps only the unlocked ones: this section is a
/// teaser for what you have done, whereas the wall itself is where the locked
/// ones belong. "See more" opens that wall.
///
/// The section removes itself when there is nothing to show, rather than
/// rendering a heading over an empty space.
class ChallengePreviousAchievements extends StatefulWidget {
  /// How many badges the teaser shows before deferring to the wall.
  final int maxItems;

  const ChallengePreviousAchievements({super.key, this.maxItems = 3});

  @override
  State<ChallengePreviousAchievements> createState() =>
      _ChallengePreviousAchievementsState();
}

class _ChallengePreviousAchievementsState
    extends State<ChallengePreviousAchievements> {
  late final AchievementsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AchievementsCubit>()..loadWall();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementsCubit, AchievementsState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is! AchievementsWallLoaded) {
          // Silent while loading and on failure alike: this is a secondary
          // section on someone else's screen, and a spinner or an error box
          // here would be noise over the challenge the user came to see.
          return const SizedBox.shrink();
        }

        final unlocked =
            state.wall.achievements.where((a) => a.isUnlocked).toList()
              ..sort((a, b) {
                final aAt = a.unlockedAt;
                final bAt = b.unlockedAt;
                if (aAt == null || bAt == null) return 0;
                return bAt.compareTo(aAt);
              });

        if (unlocked.isEmpty) return const SizedBox.shrink();

        final shown = unlocked.take(widget.maxItems).toList();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'challenges.previous_achievements_title'.tr(),
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Only offered when the wall holds more than the teaser does.
                  if (unlocked.length > shown.length ||
                      state.wall.totalCount > unlocked.length)
                    GestureDetector(
                      onTap: () =>
                          context.push(UserAppRoutes.achievementsWall),
                      child: Row(
                        children: [
                          Text(
                            'challenges.see_more'.tr(),
                            style: TextStyleManager.style11Medium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Directionality.of(context) == ui.TextDirection.rtl
                                ? Icons.keyboard_double_arrow_left_rounded
                                : Icons.keyboard_double_arrow_right_rounded,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              for (int i = 0; i < shown.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: AchievementRow(achievement: shown[i]),
                ),
            ],
          ),
        );
      },
    );
  }
}
