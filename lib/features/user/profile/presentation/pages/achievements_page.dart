import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:fitness_day/features/user/challenges/data/models/achievement_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/achievements_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/visit_log/week_calendar_strip.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/visit_log/week_navigation_header.dart';

/// Achievements — `GET /achievements/daily`.
///
/// The badges are unlocked automatically on the server during an activity
/// sync; nothing here claims or earns one, it only reads what happened.
///
/// The seven chips come straight from the response's `week`, which is seven
/// days **ending on** the selected date rather than a calendar week. That is
/// also why the day strip is not derived from the device clock: days are
/// bucketed in Asia/Riyadh, and `dayKey` is the authoritative label.
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AchievementsCubit>()..loadDay(),
      child: const _AchievementsView(),
    );
  }
}

class _AchievementsView extends StatelessWidget {
  const _AchievementsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.profileGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: AppBackHeader(title: 'profile_page.achievements'.tr()),
              ),
              Expanded(
                child: BlocBuilder<AchievementsCubit, AchievementsState>(
                  builder: (context, state) => switch (state) {
                    AchievementsError(:final message, :final error) =>
                      AppErrorView(
                        error: error,
                        message: message,
                        onRetry: () =>
                            context.read<AchievementsCubit>().loadDay(),
                      ),
                    AchievementsDailyLoaded() => _DailyView(state: state),
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
}

// ─── Loaded day ───────────────────────────────────────────────────────────────

class _DailyView extends StatelessWidget {
  final AchievementsDailyLoaded state;

  const _DailyView({required this.state});

  /// `yyyy-MM-dd` → DateTime, for the strip's formatting only. Parsing failures
  /// fall back to today rather than throwing: the label matters less than the
  /// screen staying up.
  static DateTime _parseDayKey(String dayKey) =>
      DateTime.tryParse(dayKey) ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final week = state.daily.week;
    final weekDays = week.map((d) => _parseDayKey(d.dayKey)).toList();

    // The dot marks days that actually earned something; every chip stays
    // tappable, because "nothing that day" is an answer worth showing.
    final unlockedKeys = {
      for (final day in week)
        if (day.count > 0) day.dayKey,
    };
    final selectableKeys = week.map((d) => d.dayKey).toSet();

    final selectedIndex = week.indexWhere((d) => d.dayKey == state.daily.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 4.h),
        if (weekDays.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: WeekNavigationHeader(
              weekStart: weekDays.first,
              weekEnd: weekDays.last,
              // Each step moves the anchor a full seven days, which is what
              // the endpoint's window is measured in.
              onPrevious: () => _shiftWeek(context, -7),
              onNext: () => _shiftWeek(context, 7),
              isPreviousEnabled: !state.isSwitchingDay,
              // Never past today: the endpoint has nothing to report for a day
              // that has not happened.
              isNextEnabled: !state.isSwitchingDay && _canGoForward(weekDays),
            ),
          ),
        SizedBox(height: 12.h),
        if (weekDays.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: WeekCalendarStrip(
              weekDays: weekDays,
              appointmentDateKeys: unlockedKeys,
              selectableDateKeys: selectableKeys,
              selectedIndex: selectedIndex < 0 ? week.length - 1 : selectedIndex,
              onDaySelected: (i) => context
                  .read<AchievementsCubit>()
                  .loadDay(date: week[i].dayKey),
            ),
          ),
        SizedBox(height: 24.h),
        Expanded(
          child: Stack(
            children: [
              if (state.daily.achievements.isEmpty)
                const _EmptyState()
              else
                _AchievementsList(achievements: state.daily.achievements),
              // The strip stays put while another day loads, rather than the
              // whole screen collapsing to a spinner.
              if (state.isSwitchingDay)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33FFFFFF),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// The window already reaches today, so there is no later one to show.
  bool _canGoForward(List<DateTime> weekDays) {
    final today = DateTime.now();
    return weekDays.last.isBefore(DateTime(today.year, today.month, today.day));
  }

  void _shiftWeek(BuildContext context, int days) {
    final anchor = _parseDayKey(state.daily.date).add(Duration(days: days));
    final today = DateTime.now();
    final capped = anchor.isAfter(today) ? today : anchor;
    context
        .read<AchievementsCubit>()
        .loadDay(date: WeekCalendarStrip.dateKey(capped));
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppImages.achievement,
            width: 240.w,
            height: 220.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 24.h),
          Text(
            'achievements.empty_title'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.heading2.copyWith(color: AppColors.primary),
          ),
          SizedBox(height: 10.h),
          Text(
            'achievements.empty_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.style13Medium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

// ─── List ─────────────────────────────────────────────────────────────────────

class _AchievementsList extends StatelessWidget {
  final List<AchievementModel> achievements;

  const _AchievementsList({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: achievements.length,
          separatorBuilder: (_, _) => Divider(
            height: 10.h,
            thickness: 0.8,
            color: AppColors.divider.withValues(alpha: 0.5),
          ),
          itemBuilder: (context, index) => AchievementRow(
            achievement: achievements[index],
            isFirst: index == 0,
            isLast: index == achievements.length - 1,
          ),
        ),
      ),
    );
  }
}

// ─── Row ──────────────────────────────────────────────────────────────────────

/// One badge. Shared with the unlock celebration, so it is not private.
class AchievementRow extends StatelessWidget {
  final AchievementModel achievement;
  final bool isFirst;
  final bool isLast;

  const AchievementRow({
    super.key,
    required this.achievement,
    this.isFirst = true,
    this.isLast = true,
  });

  /// Artwork is uploaded from the dashboard and is null until someone does it,
  /// so every badge needs something to fall back on. Keyed off `code`, the one
  /// stable field — never off `name`, which is editable and translated.
  static String iconFor(String code) => switch (code) {
        'hydration_hero' => SvgIcons.waterBorder,
        'steps_king' => SvgIcons.wake,
        'consistency' => SvgIcons.success,
        'month_champion' => SvgIcons.achievement,
        _ => SvgIcons.achievement,
      };

  @override
  Widget build(BuildContext context) {
    // Locked badges are shown too — the wall is meant to say what there is to
    // aim for — but visibly dimmed.
    final double opacity = achievement.isUnlocked ? 1.0 : 0.45;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? Radius.circular(16.r) : Radius.zero,
        bottom: isLast ? Radius.circular(16.r) : Radius.zero,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and description come from the dashboard, already
                      // translated to the `lang` header — never hardcoded here.
                      Text(
                        achievement.name,
                        style: TextStyleManager.style14Bold.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        achievement.description,
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                _AchievementIcon(achievement: achievement),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementIcon extends StatelessWidget {
  final AchievementModel achievement;

  const _AchievementIcon({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final String? image = achievement.image;
    return SizedBox(
      width: 48.r,
      height: 48.r,
      child: Center(
        child: AppImage(
          image == null || image.isEmpty
              ? AchievementRow.iconFor(achievement.code)
              : image,
          width: 48.r,
          height: 48.r,
        ),
      ),
    );
  }
}
