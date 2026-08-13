import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/achievements_cubit.dart';
import 'package:fitness_day/features/user/profile/presentation/pages/achievements_page.dart';

/// The full badge wall — `GET /achievements`.
///
/// Distinct from the day-strip screen, which only answers "what did I unlock on
/// this date". This one lists **everything there is**, locked included: badges
/// the user has yet to earn are the reason the screen exists, so they are never
/// filtered out — only dimmed.
class AchievementsWallPage extends StatelessWidget {
  const AchievementsWallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AchievementsCubit>()..loadWall(),
      child: const _WallView(),
    );
  }
}

class _WallView extends StatelessWidget {
  const _WallView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: AppBackHeader(title: 'achievements.wall_title'.tr()),
              ),
              Expanded(
                child: BlocBuilder<AchievementsCubit, AchievementsState>(
                  builder: (context, state) => switch (state) {
                    AchievementsError(:final message, :final error) =>
                      AppErrorView(
                        error: error,
                        message: message,
                        onRetry: () =>
                            context.read<AchievementsCubit>().loadWall(),
                      ),
                    AchievementsWallLoaded(:final wall) =>
                      wall.achievements.isEmpty
                          ? _empty()
                          : _list(context, state),
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

  Widget _empty() => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'achievements.wall_empty'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.style13Medium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );

  Widget _list(BuildContext context, AchievementsWallLoaded state) {
    final wall = state.wall;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<AchievementsCubit>().loadWall(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(22.w, 4.h, 22.w, 24.h),
        children: [
          Text(
            // Both numbers come from the server; the app never counts the list
            // itself, so a paged or filtered response can't disagree with it.
            'achievements.unlocked_count'.tr(
              args: ['${wall.unlockedCount}', '${wall.totalCount}'],
            ),
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          for (int i = 0; i < wall.achievements.length; i++) ...[
            AchievementRow(
              achievement: wall.achievements[i],
              isFirst: i == 0,
              isLast: i == wall.achievements.length - 1,
            ),
            if (i != wall.achievements.length - 1)
              Divider(
                height: 10.h,
                thickness: 0.8,
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}
