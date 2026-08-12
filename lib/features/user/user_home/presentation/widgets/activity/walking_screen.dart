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
import 'package:fitness_day/features/user/user_home/presentation/manager/walking_cubit.dart';

// ═════════════════════════════════════════════════════════════════════════════
// WALKING SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class WalkingScreen extends StatefulWidget {
  final double apiProgress;
  final int apiProgressPercent;
  final ActivityDetailsCubit activityCubit;

  const WalkingScreen({
    super.key,
    this.apiProgress = 0,
    this.apiProgressPercent = 0,
    required this.activityCubit,
  });

  @override
  State<WalkingScreen> createState() => _WalkingScreenState();
}

class _WalkingScreenState extends State<WalkingScreen>
    with WidgetsBindingObserver {
  int _selectedTab = 0;

  /// Weekly is a read-only aggregate kept in its own field. Keeping it separate
  /// from the frozen daily baseline is what stops the weekly figures from
  /// leaking into the daily session total when the user switches tabs mid-walk.
  ActivityDetailsData? _weeklyData;

  /// API snapshot frozen at the moment the screen first loads (or after a
  /// session ends). These are NOT updated mid-session so live sensor deltas
  /// accumulate on top of a stable baseline and never jump back.
  late double _frozenApiProgress;
  late double _frozenApiGoal;
  late String _frozenApiUnit;
  late String _frozenActivityName;
  late double _frozenApiDistance;
  late int _frozenApiDurationSeconds;
  late int _frozenApiCalories;

  /// Today's target is already met — the start button is hidden, since there is
  /// nothing left to track. Server-owned: the app never decides this by
  /// comparing progress against the goal itself.
  late bool _goalReached;

  // A getter, not a field: resolving at build time keeps the labels correct
  // when the user switches language without leaving the screen.
  List<String> get _tabs => [
        'activity_tracking.tab_daily'.tr(),
        'activity_tracking.tab_weekly'.tr(),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _freezeFromWidget();
    // The parent consumed the first ActivityDetailsSuccess before this screen
    // subscribed, so the BlocConsumer listener never replays it. Seed the frozen
    // baseline from the cubit's current state so goal/unit aren't left at their
    // zero defaults — that's what showed "/ 0 steps" and "0%" on the idle daily
    // view.
    final actState = widget.activityCubit.state;
    if (actState is ActivityDetailsSuccess) {
      _applyApiData(actState.data);
    }
  }

  @override
  void didUpdateWidget(WalkingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Weekly keeps its own data; only the daily baseline is prop-driven.
    if (_selectedTab != 0) return;
    // Only accept fresh API data when no session is running — mid-session
    // updates would reset the live step display back to the server snapshot.
    final walkingCubit = context.read<WalkingCubit>();
    if (!walkingCubit.state.isTracking) {
      // Re-freeze from the cubit's current API data, NOT _freezeFromWidget():
      // the parent re-runs this build right after its own listener's setState,
      // and _freezeFromWidget() zeroes the goal — which is exactly what made the
      // circle fall back to "/ 0 steps" and "0%" after the first frame.
      final actState = widget.activityCubit.state;
      if (actState is ActivityDetailsSuccess) {
        _applyApiData(actState.data);
      } else {
        _freezeFromWidget();
      }
    }
  }

  void _freezeFromWidget() {
    _frozenApiProgress = widget.apiProgress;
    _frozenApiGoal = 0; // resolved from cubit/activityCubit in build
    _frozenApiUnit = 'activity_tracking.steps_unit'.tr();
    _frozenActivityName = 'activity_tracking.walking_title'.tr();
    _frozenApiDistance = 0;
    _frozenApiDurationSeconds = 0;
    _frozenApiCalories = 0;
    _goalReached = false;
  }

  /// Called once after the first successful API load and again after each
  /// stop-and-refresh cycle, but never mid-session.
  void _applyApiData(ActivityDetailsData data) {
    _frozenApiProgress = data.currentProgress;
    _frozenApiGoal = data.goal;
    _frozenApiUnit = data.unit.isNotEmpty ? data.unit : 'activity_tracking.steps_unit'.tr();
    _frozenActivityName = data.name.isNotEmpty ? data.name : 'activity_tracking.walking_title'.tr();
    _frozenApiDistance = data.distance ?? 0;
    _frozenApiDurationSeconds = apiDurationSeconds(data.durationMinutes);
    _frozenApiCalories = data.caloriesBurned?.round() ?? 0;
    _goalReached = data.goalReached;
  }

  void _onTabChanged(int index, BuildContext context) {
    setState(() => _selectedTab = index);
    _refreshDetails();
  }

  Future<void> _refreshDetails() {
    return widget.activityCubit.getActivityDetails(
      widget.activityCubit.assessmentId,
      widget.activityCubit.dayNumber,
      widget.activityCubit.activityId,
      period: _selectedTab == 0 ? 'daily' : 'weekly',
    );
  }

  /// The frozen baseline only protects the daily tab, where the running session
  /// is layered on top of it. Weekly figures come straight from the API.
  bool _isFrozenForSession(BuildContext context) =>
      _selectedTab == 0 && context.read<WalkingCubit>().state.isTracking;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<WalkingCubit>();
    if (state == AppLifecycleState.resumed) {
      cubit.resumeTracking();
    } else if (state == AppLifecycleState.paused) {
      cubit.pauseTracking();
    }
  }

  Future<void> _onToggleTracking(BuildContext context, bool isTracking) async {
    final cubit = context.read<WalkingCubit>();

    if (isTracking) {
      // Await the final sync so isTracking is already false when the GET
      // response arrives — the listener will then correctly apply the new
      // server data to the frozen baseline.
      await cubit.stopTracking();
      if (!mounted) return;

      // Fold the session into the baseline right away. The display is
      // `baseline + session steps`, and stopping drops the session term to
      // zero — without this the total visibly falls back to its pre-session
      // value until the refresh lands, and stays there if the refresh fails.
      // Those steps are already synced, so counting them here is correct; the
      // refresh then overwrites this with the server's authoritative total.
      setState(() => _frozenApiProgress += cubit.state.steps.toDouble());
      _refreshDetails();
      return;
    }

    // Refresh *before* starting: the new session restarts its step count at
    // zero, so a stale baseline would show a total lower than the server's.
    await _refreshDetails();
    if (!mounted) return;
    cubit.startTracking();
  }


  /// Read-only weekly aggregate — steps + summary straight from the API, with
  /// no live tracking and no start/stop button (you can't run a session "for
  /// the week").
  Widget _buildWeeklyView() {
    final data = _weeklyData;
    final double steps = data?.currentProgress ?? 0;
    final double goal = data?.goal ?? 0;
    final String unit = (data?.unit.isNotEmpty ?? false)
        ? data!.unit
        : 'activity_tracking.steps_unit'.tr();
    final double percent = goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              buildActivityAppBar(context, _frozenActivityName),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: PeriodTabBar(
                  tabs: _tabs,
                  selectedIndex: _selectedTab,
                  onTabChanged: (i) => _onTabChanged(i, context),
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
                  currentVal: steps,
                  goalVal: goal,
                  unit: unit,
                  goalPercent: (percent * 100).round(),
                ),
                SizedBox(height: 32.h),
                Expanded(
                  child: DailySummaryCard(
                    title: 'activity_tracking.week_summary'.tr(),
                    distance: data.distance ?? 0,
                    unit: 'activity_tracking.km_unit'.tr(),
                    durationSeconds: apiDurationSeconds(data.durationMinutes),
                    calories: data.caloriesBurned?.round() ?? 0,
                    isWalking: true,
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
      // Mid-session API updates would jump the displayed step count back to the
      // server snapshot and erase the live sensor delta — but only on the daily
      // tab, which is the one the session contributes to. The weekly tab shows
      // pure API figures, so it must keep refreshing even while tracking.
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
        // Weekly is a pure aggregate: no live session, no start/stop button.
        if (_selectedTab == 1) return _buildWeeklyView();
        return BlocBuilder<WalkingCubit, WalkingState>(
          builder: (context, state) {
            final bool showLive = _selectedTab == 0 && state.isTracking;
            final double currentSteps =
                _frozenApiProgress + (showLive ? state.steps.toDouble() : 0);
            final double goal = showLive ? state.goalSteps : _frozenApiGoal;
            final double currentPercent =
                goal > 0 ? (currentSteps / goal).clamp(0.0, 1.0) : 0.0;
            final int currentPercentInt = (currentPercent * 100).round();

            return Scaffold(
              body: ScreenBackground(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      buildActivityAppBar(context, _frozenActivityName),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: PeriodTabBar(
                          tabs: _tabs,
                          selectedIndex: _selectedTab,
                          onTabChanged: (i) => _onTabChanged(i, context),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      ActivityCircle(
                        percent: currentPercent,
                        currentVal: currentSteps,
                        goalVal: goal,
                        unit: _frozenApiUnit,
                        goalPercent: currentPercentInt,
                      ),
                      SizedBox(height: 16.h),

                      // Same stopwatch the running screen shows, driven by the
                      // walking cubit's clock.
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

                      // Permission banner sits directly under the clock when
                      // needed — kept separate from the space/summary choice
                      // below so it never pushes the start button up.
                      if (state.permissionStatus == HealthPermStatus.needsInstall)
                        PermissionBanner(
                          message: 'activity_tracking.install_health_connect'.tr(),
                          onTap: () =>
                              context.read<WalkingCubit>().installHealthConnect(),
                        )
                      else if (state.permissionStatus == HealthPermStatus.denied)
                        PermissionBanner(
                          message: 'activity_tracking.grant_health_access'.tr(),
                          onTap: () =>
                              context.read<WalkingCubit>().startTracking(),
                        ),

                      // Always on screen, like the running view: the day's
                      // figures come from the server, so there is something to
                      // show before a session ever starts. The live session is
                      // layered on top only while tracking.
                      Expanded(
                        child: DailySummaryCard(
                          distance: _frozenApiDistance +
                              (showLive ? state.distanceKm : 0),
                          unit: 'activity_tracking.km_unit'.tr(),
                          durationSeconds: _frozenApiDurationSeconds +
                              (showLive ? state.elapsedSeconds : 0),
                          calories: _frozenApiCalories +
                              (showLive ? state.caloriesKcal.round() : 0),
                          isWalking: true,
                        ),
                      ),

                      // Target met → nothing left to track today, so the start
                      // button goes away. A session already running keeps its
                      // stop button, otherwise the user could not end it.
                      if (!_goalReached || state.isTracking) ...[
                        StartStopButton(
                          isRunning: state.isTracking,
                          onTap: () =>
                              _onToggleTracking(context, state.isTracking),
                        ),
                        SizedBox(height: 24.h),
                      ] else
                        SizedBox(height: 24.h),
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
