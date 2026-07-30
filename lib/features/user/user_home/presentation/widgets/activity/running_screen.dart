import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/activity_details_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/activity_details_state.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/activity_app_bar.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/activity_circle.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/activity_duration.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/daily_summary_card.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/period_tab_bar.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/permission_banner.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/start_stop_button.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/running_cubit.dart';

// ═════════════════════════════════════════════════════════════════════════════
// RUNNING SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class RunningScreen extends StatefulWidget {
  final double apiProgress;
  final int apiProgressPercent;
  final int apiDurationSeconds;
  final double apiCalories;
  final ActivityDetailsCubit activityCubit;

  const RunningScreen({
    super.key,
    this.apiProgress = 0,
    this.apiProgressPercent = 0,
    this.apiDurationSeconds = 0,
    this.apiCalories = 0,
    required this.activityCubit,
  });

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  int _selectedTab = 0;

  /// Weekly aggregate, read-only and kept apart from the daily session baseline
  /// so switching tabs mid-run can't corrupt the daily distance.
  ActivityDetailsData? _weeklyData;

  /// API snapshot frozen at screen open (or after a session ends).
  /// Never updated mid-session so the live GPS distance doesn't jump back.
  late double _frozenApiProgress;
  late int _frozenApiProgressPct;
  late double _frozenApiGoal;
  late String _frozenApiUnit;
  late String _frozenActivityName;
  late int _frozenApiDuration;
  late double _frozenApiCalories;

  /// Today's target is already met — the start button is hidden, since there is
  /// nothing left to track. Server-owned: the app never decides this by
  /// comparing progress against the goal itself.
  bool _goalReached = false;

  List<String> get _tabs => [
        'activity_tracking.tab_daily'.tr(),
        'activity_tracking.tab_weekly'.tr(),
      ];

  @override
  void initState() {
    super.initState();
    _frozenApiProgress = widget.apiProgress;
    _frozenApiProgressPct = widget.apiProgressPercent;
    _frozenApiGoal = 0;
    _frozenApiUnit = 'activity_tracking.km_unit'.tr();
    _frozenActivityName = 'activity_tracking.running_title'.tr();
    _frozenApiDuration = widget.apiDurationSeconds;
    _frozenApiCalories = widget.apiCalories;
    // Same first-load gap as the walking screen: the initial success was already
    // emitted before this screen subscribed, so seed the goal/unit from the
    // cubit's current state instead of leaving the goal at 0.
    final actState = widget.activityCubit.state;
    if (actState is ActivityDetailsSuccess) {
      _applyApiData(actState.data);
    }
  }

  void _applyApiData(ActivityDetailsData data) {
    _frozenApiProgress = data.currentProgress;
    _frozenApiProgressPct = data.progressPercentage.toInt();
    _frozenApiGoal = data.goal;
    _frozenApiUnit = data.unit.isNotEmpty ? data.unit : 'activity_tracking.km_unit'.tr();
    _frozenActivityName = data.name.isNotEmpty ? data.name : 'activity_tracking.running_title'.tr();
    _frozenApiDuration = apiDurationSeconds(data.durationMinutes);
    _frozenApiCalories = data.caloriesBurned ?? 0;
    _goalReached = data.goalReached;
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTab = index);
    _refreshDetails();
  }

  void _refreshDetails() {
    widget.activityCubit.getActivityDetails(
      widget.activityCubit.assessmentId,
      widget.activityCubit.dayNumber,
      widget.activityCubit.activityId,
      period: _selectedTab == 0 ? 'daily' : 'weekly',
    );
  }

  /// The frozen baseline only protects the daily tab, where the run is layered
  /// on top of it. Weekly figures come straight from the API.
  bool _isFrozenForSession(BuildContext context) =>
      _selectedTab == 0 && context.read<RunningCubit>().state.isRunning;

  /// Stop triggers a refresh so the summary card reflects the finished run.
  /// Start does NOT refresh — the screen already loaded the data when it
  /// opened, and refreshing here would reset live GPS figures mid-session.
  Future<void> _onToggleSession(BuildContext context, bool isRunning) async {
    final cubit = context.read<RunningCubit>();
    if (isRunning) {
      await cubit.stopSession();
      if (!mounted) return;

      // Fold the finished session into the baseline. The display is
      // `baseline + session`, and stopping drops the session term to zero —
      // without this the number visibly falls back to its pre-run value until
      // the refresh lands. Those metres are already synced, so counting them
      // here is correct; the refresh then replaces this with the server's
      // authoritative total. Mirrors what the walking screen does on stop.
      setState(() {
        _frozenApiProgress += cubit.state.distanceKm;
        _frozenApiDuration += cubit.state.elapsedSeconds;
      });
      _refreshDetails();
      return;
    }
    await cubit.startSession();
  }

  /// Read-only weekly aggregate — distance + summary straight from the API,
  /// with no live run and no start/stop button.
  Widget _buildWeeklyView() {
    final data = _weeklyData;
    final double progress = data?.currentProgress ?? 0;
    final double goal = data?.goal ?? 0;
    final String unit = (data?.unit.isNotEmpty ?? false)
        ? data!.unit
        : 'activity_tracking.km_unit'.tr();
    final double percent = goal > 0
        ? (progress / goal).clamp(0.0, 1.0)
        : (data != null ? (data.progressPercentage / 100).clamp(0.0, 1.0) : 0.0);

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              buildActivityAppBar(context, _frozenActivityName),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: PeriodTabBar(
                  tabs: _tabs,
                  selectedIndex: _selectedTab,
                  onTabChanged: _onTabChanged,
                ),
              ),
              SizedBox(height: 40.h),
              if (data == null)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else ...[
                ActivityCircle(
                  percent: percent,
                  currentVal: progress,
                  goalVal: goal,
                  unit: unit,
                  goalPercent: (percent * 100).round(),
                  decimals: 2,
                ),
                SizedBox(height: 32.h),
                Expanded(
                  child: DailySummaryCard(
                    title: 'activity_tracking.week_summary'.tr(),
                    distance: progress,
                    unit: unit,
                    durationSeconds: apiDurationSeconds(data.durationMinutes),
                    calories: data.caloriesBurned?.round() ?? 0,
                    isWalking: false,
                  ),
                ),
              ],
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityDetailsCubit, ActivityDetailsState>(
      bloc: widget.activityCubit,
      // Freeze only the daily tab, which the run is layered onto. The weekly
      // tab shows pure API figures and must keep refreshing mid-run.
      listenWhen: (_, curr) => curr is ActivityDetailsSuccess,
      listener: (context, actState) {
        if (actState is ActivityDetailsSuccess) {
          if (_selectedTab == 1) {
            // Weekly view — store separately, never touch the daily baseline.
            setState(() => _weeklyData = actState.data);
          } else if (!_isFrozenForSession(context)) {
            setState(() => _applyApiData(actState.data));
          }
        }
      },
      buildWhen: (prev, curr) {
        if (_isFrozenForSession(context)) return false;
        return curr is ActivityDetailsSuccess || curr is ActivityDetailsFailure;
      },
      builder: (context, actState) {
        // Weekly is a pure aggregate: no live run, no start/stop button.
        if (_selectedTab == 1) return _buildWeeklyView();
        return BlocBuilder<RunningCubit, RunningState>(
          builder: (context, state) {
            // Session figures belong to today only — on the weekly tab always
            // show what the API returned.
            //
            // Tied to `isRunning`, not to `distanceKm > 0`: the cubit keeps the
            // finished session's distance in state after stop, so the old test
            // stayed true and kept adding it on top of a refreshed baseline that
            // already included it — a 0.26 km run displayed as 0.28.
            final bool showLive =
                _selectedTab == 0 && state.isRunning && state.distanceKm > 0;

            // The run adds to the day's total rather than replacing it: the
            // circle showed only the current session's distance, so a user who
            // had already covered ground saw the number collapse on start.
            // Both terms are kilometres, so they add directly.
            final double total =
                _frozenApiProgress + (showLive ? state.distanceKm : 0);
            final double totalPercent = _frozenApiGoal > 0
                ? (total / _frozenApiGoal).clamp(0.0, 1.0)
                : (_frozenApiProgressPct / 100.0).clamp(0.0, 1.0);

            return Scaffold(
              body: ScreenBackground(
                child: SafeArea(
                  child: Column(
                    children: [
                      buildActivityAppBar(context, _frozenActivityName),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: PeriodTabBar(
                          tabs: _tabs,
                          selectedIndex: _selectedTab,
                          onTabChanged: _onTabChanged,
                        ),
                      ),
                      SizedBox(height: 40.h),

                      if (!state.permissionGranted)
                        PermissionBanner(
                          message: 'activity_tracking.needs_location_motion'.tr(),
                          onTap: () =>
                              context.read<RunningCubit>().requestPermissions(),
                        )
                      else ...[
                        ActivityCircle(
                          percent: totalPercent,
                          currentVal: total,
                          goalVal: _frozenApiGoal,
                          unit: _frozenApiUnit,
                          goalPercent: (totalPercent * 100).round(),
                          decimals: 2,
                        ),
                        SizedBox(height: 16.h),

                        Text(
                          state.formattedTime,
                          style: TextStyleManager.style28Bold.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'activity_tracking.elapsed_time'.tr(),
                          style: TextStyleManager.style11Medium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        SizedBox(height: 24.h),

                        // Server totals with the running session layered on, so
                        // the card moves during a run instead of sitting on the
                        // snapshot taken when it started. Calories are the one
                        // exception: the sync response already returns the
                        // activity's cumulative total, so it replaces rather
                        // than adds.
                        Expanded(
                          child: DailySummaryCard(
                            distance: total,
                            unit: _frozenApiUnit,
                            durationSeconds: _frozenApiDuration +
                                (showLive ? state.elapsedSeconds : 0),
                            calories: state.caloriesKcal > 0
                                ? state.caloriesKcal.round()
                                : _frozenApiCalories.round(),
                            isWalking: false,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Target met → nothing left to track today, so the
                        // start button goes away. A run already in progress
                        // keeps its stop button, otherwise the user could not
                        // end it.
                        if (!_goalReached || state.isRunning)
                          StartStopButton(
                            isRunning: state.isRunning,
                            onTap: () =>
                                _onToggleSession(context, state.isRunning),
                          ),
                        SizedBox(height: 24.h),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
