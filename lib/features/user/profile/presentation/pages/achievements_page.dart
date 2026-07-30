import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/visit_log/week_calendar_strip.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/visit_log/week_navigation_header.dart';

/// Achievements page.
///
/// Uses the exact same [WeekCalendarStrip] + [WeekNavigationHeader] as the
/// Visit Log page, driven by local StatefulWidget state (no cubit needed).
///
/// "Today" is always highlighted; days with an achievement are marked with
/// the green tint + dot — the same visual language as appointment days in
/// the visit log.
class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  // ── Calendar state ────────────────────────────────────────────────────────
  // Start the view on the week containing today (July 30, 2026 = Wednesday).
  // Saturday is the first day of the Arabic week.
  late DateTime _weekStart; // always a Saturday
  int _selectedDayIndex = 0;

  // ── Mock achievements ─────────────────────────────────────────────────────
  static final  List<_Achievement> _achievements = [
    _Achievement(
      titleKey: 'achievements.hydration_hero_title',
      subtitleKey: 'achievements.hydration_hero_subtitle',
      iconPath: SvgIcons.waterBorder,
    ),
    _Achievement(
      titleKey: 'achievements.steps_king_title',
      subtitleKey: 'achievements.steps_king_subtitle',
      iconPath: SvgIcons.wake,
    ),
    _Achievement(
      titleKey: 'achievements.month_hero_title',
      subtitleKey: 'achievements.month_hero_subtitle',
      iconPath: SvgIcons.achievement,
    ),
    _Achievement(
      titleKey: 'achievements.consistency_title',
      subtitleKey: 'achievements.consistency_subtitle',
      iconPath: SvgIcons.success,
    ),
  ];

  // Days that have at least one achievement (date-only keys "yyyy-MM-dd").
  // In production these would come from the API / cubit.
  late final Set<String> _achievementDateKeys;

  // How many weeks back the user can navigate (arbitrary limit for mock).
  static const int _maxPastWeeks = 8;
  int _weekOffset = 0; // 0 = current week, negative = past

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();
    _weekStart = _saturdayOf(today);

    // Mock: mark a few days in the current week as "achievement days"
    _achievementDateKeys = {
      WeekCalendarStrip.dateKey(today),
      WeekCalendarStrip.dateKey(today.subtract(const Duration(days: 1))),
      WeekCalendarStrip.dateKey(today.subtract(const Duration(days: 2))),
    };

    // Pre-select today's column
    _selectedDayIndex = _indexOfDate(today, _weekStart);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the Saturday that starts the week containing [date].
  DateTime _saturdayOf(DateTime date) {
    // weekday: Mon=1 … Sun=7; Saturday = 6
    final int diff = (date.weekday % 7 + 1) % 7; // days since last Saturday
    return DateTime(date.year, date.month, date.day - diff);
  }

  List<DateTime> get _weekDays => List.generate(
        7,
        (i) => DateTime(
          _weekStart.year,
          _weekStart.month,
          _weekStart.day + i,
        ),
      );

  int _indexOfDate(DateTime date, DateTime weekStart) {
    final key = WeekCalendarStrip.dateKey(date);
    final days = List.generate(
      7,
      (i) => DateTime(weekStart.year, weekStart.month, weekStart.day + i),
    );
    final idx = days.indexWhere((d) => WeekCalendarStrip.dateKey(d) == key);
    return idx < 0 ? 0 : idx;
  }

  void _goToPreviousWeek() {
    setState(() {
      _weekOffset--;
      _weekStart = DateTime(
        _weekStart.year,
        _weekStart.month,
        _weekStart.day - 7,
      );
      _selectedDayIndex = 0;
    });
  }

  void _goToNextWeek() {
    setState(() {
      _weekOffset++;
      _weekStart = DateTime(
        _weekStart.year,
        _weekStart.month,
        _weekStart.day + 7,
      );
      _selectedDayIndex = 0;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final weekDays = _weekDays;
    final weekEnd = weekDays.last;
    final bool canGoPrev = _weekOffset > -_maxPastWeeks;
    final bool canGoNext = _weekOffset < 0; // can't go past current week

    // Show achievements list only when there are any; otherwise empty state.
    final bool hasAchievements = _achievements.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.profileGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: AppBackHeader(
                  title: 'profile_page.achievements'.tr(),
                ),
              ),

              SizedBox(height: 4.h),

              // ── Week navigation header (identical to Visit Log) ───────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: WeekNavigationHeader(
                  weekStart: _weekStart,
                  weekEnd: weekEnd,
                  onPrevious: _goToPreviousWeek,
                  onNext: _goToNextWeek,
                  isPreviousEnabled: canGoPrev,
                  isNextEnabled: canGoNext,
                ),
              ),

              SizedBox(height: 12.h),

              // ── 7-day calendar strip (identical to Visit Log) ────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: WeekCalendarStrip(
                  weekDays: weekDays,
                  // Reuse appointmentDateKeys slot for achievement days —
                  // same visual: green tint + dot on days with achievements.
                  appointmentDateKeys: _achievementDateKeys,
                  selectedIndex: _selectedDayIndex,
                  onDaySelected: (i) {
                    if (_achievementDateKeys.contains(
                      WeekCalendarStrip.dateKey(weekDays[i]),
                    )) {
                      setState(() => _selectedDayIndex = i);
                    }
                  },
                ),
              ),

              SizedBox(height: 24.h),

              // ── Body: empty state or achievements list ────────────────────
              Expanded(
                child: hasAchievements
                    ? _AchievementsList(achievements: _achievements)
                    : const _EmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

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
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.primary,
            ),
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

// ─── Achievements List ────────────────────────────────────────────────────────

class _AchievementsList extends StatelessWidget {
  final List<_Achievement> achievements;

  const _AchievementsList({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        
          // boxShadow: [
          //   BoxShadow(
          //     color: AppColors.black.withValues(alpha: 0.04),
          //     blurRadius: 8,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: achievements.length,
          separatorBuilder: (_, __) => Divider(
            height: 10.h,
            thickness: 0.8,
            color: AppColors.divider.withValues(alpha: 0.5),
          ),
          itemBuilder: (context, index) => _AchievementRow(
            achievement: achievements[index],
            isFirst: index == 0,
            isLast: index == achievements.length - 1,
          ),
        ),
      ),
    );
  }
}

// ─── Achievement Row ──────────────────────────────────────────────────────────

class _AchievementRow extends StatelessWidget {
  final _Achievement achievement;
  final bool isFirst;
  final bool isLast;

  const _AchievementRow({
    required this.achievement,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
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
          boxShadow:  [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              // Text — leading edge in both RTL and LTR
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.titleKey.tr(),
                      style: TextStyleManager.style14Bold.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      achievement.subtitleKey.tr(),
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Icon — trailing edge (right in LTR, left in RTL)
              _AchievementIcon(iconPath: achievement.iconPath),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Achievement Icon ─────────────────────────────────────────────────────────

class _AchievementIcon extends StatelessWidget {
  final String iconPath;

  const _AchievementIcon({required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.r,
      height: 48.r,
      decoration: BoxDecoration(
      
        shape: BoxShape.circle,
      
      ),
      child: Center(
        child: AppImage(iconPath, width: 48.r, height: 48.r),
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class _Achievement {
  final String titleKey;
  final String subtitleKey;
  final String iconPath;

  const _Achievement({
    required this.titleKey,
    required this.subtitleKey,
    required this.iconPath,
  });
}
