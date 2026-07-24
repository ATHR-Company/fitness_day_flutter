import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/activity_details_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/activity_details_state.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/running_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/walking_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

enum ActivityType { walking, running }

/// Running goals used to be stored in kilometres while progress was reported in
/// metres; the backend now normalises the goal to metres in the response layer.
/// Accept both so the app is correct on either side of that deploy: a running
/// goal below this threshold can only be the old kilometre form (nobody sets a
/// 100 km target), anything above it is already metres.
const double _kRunningGoalMetresThreshold = 100;

double _runningGoalKm(double rawGoal) =>
    rawGoal >= _kRunningGoalMetresThreshold ? rawGoal / 1000 : rawGoal;

/// Running progress and distance are always reported in metres, while the whole
/// screen — goal, live GPS distance, summary — works in kilometres. Converting
/// here keeps the circle from comparing metres against a kilometre goal.
double _runningProgressKm(double rawMetres) => rawMetres / 1000;

/// Diameter of the disc inside the progress ring. Fixed so the ring's centre
/// never resizes with the value; comfortably inside the 115 r ring minus its
/// 16 w stroke.
final double _kInnerDiscSize = 165.w;

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — loads activity details from API, then injects goals into cubit
// ─────────────────────────────────────────────────────────────────────────────

class StepsDetailsScreen extends StatelessWidget {
  final ActivityType type;
  final String assessmentId;
  final int dayNumber;
  final String activityId;

  const StepsDetailsScreen({
    super.key,
    this.type = ActivityType.walking,
    this.assessmentId = '',
    this.dayNumber = 1,
    this.activityId = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActivityDetailsCubit>()
        ..getActivityDetails(assessmentId, dayNumber, activityId),
      child: _StepsDetailsLoader(
        type: type,
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        activityId: activityId,
      ),
    );
  }
}

/// Waits for [ActivityDetailsCubit] to load once, then keeps the screen alive
/// while subsequent period-switch calls run in the background.
class _StepsDetailsLoader extends StatefulWidget {
  final ActivityType type;
  final String assessmentId;
  final int dayNumber;
  final String activityId;

  const _StepsDetailsLoader({
    required this.type,
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
  });

  @override
  State<_StepsDetailsLoader> createState() => _StepsDetailsLoaderState();
}

class _StepsDetailsLoaderState extends State<_StepsDetailsLoader> {
  // Cached data so the screen doesn't rebuild on period-switch loading
  ActivityDetailsData? _cachedData;
  WalkingCubit? _walkingCubit;
  RunningCubit? _runningCubit;
  bool _initialized = false;

  void _initActivityCubits(ActivityDetailsData data) {
    if (_initialized) return;
    _initialized = true;

    // RunningCubit uses GPS — always safe to create
    if (widget.type == ActivityType.running) {
      _runningCubit = RunningCubit(
        apiService: getIt(),
        assessmentId: widget.assessmentId,
        dayNumber: widget.dayNumber,
        activityId: widget.activityId,
        activityItemId: data.activityItemId,
        goalDistanceKm: _runningGoalKm(data.goal),
      );
      // Read the existing grants silently so a returning user isn't shown the
      // permission banner again. This never prompts — requestPermissions() is
      // still only triggered by the user.
      _runningCubit!.refreshPermissionStatus();
    } else {
      // Created up front like the running cubit, but idle: it reads nothing and
      // asks for no permission until the user presses start.
      _walkingCubit = WalkingCubit(
        healthService: getIt(),
        apiService: getIt(),
        assessmentId: widget.assessmentId,
        dayNumber: widget.dayNumber,
        activityId: widget.activityId,
        activityItemId: data.activityItemId,
        goalSteps: data.goal,
        // The API goal for walking is a step count; there is no distance
        // target, so don't pass the step goal as one.
        goalDistanceKm: 0,
      );
    }
  }

  /// Returns true if a walking or running session is currently active.
  bool _isSessionActive() {
    if (_walkingCubit != null) return _walkingCubit!.state.isTracking;
    if (_runningCubit != null) return _runningCubit!.state.isRunning;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityDetailsCubit, ActivityDetailsState>(
      listener: (context, state) {
        if (state is ActivityDetailsSuccess) {
          _initActivityCubits(state.data);
          // Don't trigger a parent rebuild mid-session — the child screens
          // manage their own frozen baseline and will pick up the data via
          // their own listeners once the session ends.
          if (!_isSessionActive()) {
            setState(() => _cachedData = state.data);
          } else {
            // Still update cachedData in-place without setState so the
            // data is ready for the child screens' listeners.
            _cachedData = state.data;
          }
        }
      },
      buildWhen: (prev, curr) {
        // Never rebuild the parent (and re-pass props to child screens)
        // while a session is active — doing so would push new apiProgress
        // into didUpdateWidget, which could clobber the frozen baseline.
        if (_isSessionActive()) return false;
        if (curr is ActivityDetailsLoading && _initialized) return false;
        return true;
      },
      builder: (context, state) {
        // First-time loading
        if ((state is ActivityDetailsLoading || state is ActivityDetailsInitial) &&
            !_initialized) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ActivityDetailsFailure && !_initialized) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      color: AppColors.primary, size: 48.sp),
                  SizedBox(height: 12.h),
                  Text(state.message,
                      style: TextStyleManager.style11Medium,
                      textAlign: TextAlign.center),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: Text('activity_tracking.back'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        // Use fresh data or cached data
        final data = (state is ActivityDetailsSuccess ? state.data : null) ??
            _cachedData;
        if (data == null) return const SizedBox.shrink();

        final double currentProgress = data.currentProgress;
        final int progressPercent = data.progressPercentage.toInt();
        final activityCubit = context.read<ActivityDetailsCubit>();

        if (widget.type == ActivityType.walking) {
          if (_walkingCubit == null) return const SizedBox.shrink();
          return BlocProvider.value(
            value: _walkingCubit!,
            child: _WalkingScreen(
              apiProgress: currentProgress,
              apiProgressPercent: progressPercent,
              activityCubit: activityCubit,
            ),
          );
        } else {
          if (_runningCubit == null) return const SizedBox.shrink();
          return BlocProvider.value(
            value: _runningCubit!,
            child: _RunningScreen(
              apiProgress: currentProgress,
              apiProgressPercent: progressPercent,
              apiDurationMinutes: data.durationMinutes?.toInt() ?? 0,
              apiCalories: data.caloriesBurned ?? 0,
              activityCubit: activityCubit,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _walkingCubit?.close();
    _runningCubit?.close();
    super.dispose();
  }
}


// ═════════════════════════════════════════════════════════════════════════════
// WALKING SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class _WalkingScreen extends StatefulWidget {
  final double apiProgress;
  final int apiProgressPercent;
  final ActivityDetailsCubit activityCubit;

  const _WalkingScreen({
    this.apiProgress = 0,
    this.apiProgressPercent = 0,
    required this.activityCubit,
  });

  @override
  State<_WalkingScreen> createState() => _WalkingScreenState();
}

class _WalkingScreenState extends State<_WalkingScreen>
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
  late int _frozenApiDurationMinutes;
  late int _frozenApiCalories;

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
  void didUpdateWidget(_WalkingScreen oldWidget) {
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
    _frozenApiDurationMinutes = 0;
    _frozenApiCalories = 0;
  }

  /// Called once after the first successful API load and again after each
  /// stop-and-refresh cycle, but never mid-session.
  void _applyApiData(ActivityDetailsData data) {
    _frozenApiProgress = data.currentProgress;
    _frozenApiGoal = data.goal;
    _frozenApiUnit = data.unit.isNotEmpty ? data.unit : 'activity_tracking.steps_unit'.tr();
    _frozenActivityName = data.name.isNotEmpty ? data.name : 'activity_tracking.walking_title'.tr();
    _frozenApiDistance = data.distance ?? 0;
    _frozenApiDurationMinutes = data.durationMinutes?.toInt() ?? 0;
    _frozenApiCalories = data.caloriesBurned?.round() ?? 0;
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
          child: Column(
            children: [
              _buildAppBar(context, _frozenActivityName),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: _PeriodTabBar(
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
                _ActivityCircle(
                  percent: percent,
                  currentVal: steps,
                  goalVal: goal,
                  unit: unit,
                  goalPercent: (percent * 100).round(),
                ),
                SizedBox(height: 32.h),
                Expanded(
                  child: _DailySummaryCard(
                    title: 'activity_tracking.week_summary'.tr(),
                    distanceKm: data.distance ?? 0,
                    unit: 'activity_tracking.km_unit'.tr(),
                    minutes: data.durationMinutes?.toInt() ?? 0,
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
                  child: Column(
                    children: [
                      _buildAppBar(context, _frozenActivityName),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: _PeriodTabBar(
                          tabs: _tabs,
                          selectedIndex: _selectedTab,
                          onTabChanged: (i) => _onTabChanged(i, context),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      _ActivityCircle(
                        percent: currentPercent,
                        currentVal: currentSteps,
                        goalVal: goal,
                        unit: _frozenApiUnit,
                        goalPercent: currentPercentInt,
                      ),
                      SizedBox(height: 32.h),

                      // Permission banner sits directly under the circle when
                      // needed — kept separate from the space/summary choice
                      // below so it never pushes the start button up.
                      if (state.permissionStatus == HealthPermStatus.needsInstall)
                        _PermissionBanner(
                          message: 'activity_tracking.install_health_connect'.tr(),
                          onTap: () =>
                              context.read<WalkingCubit>().installHealthConnect(),
                        )
                      else if (state.permissionStatus == HealthPermStatus.denied)
                        _PermissionBanner(
                          message: 'activity_tracking.grant_health_access'.tr(),
                          onTap: () =>
                              context.read<WalkingCubit>().startTracking(),
                        ),

                      // Summary while tracking, otherwise flexible space — either
                      // way the start/stop button stays pinned to the bottom.
                      if (state.isTracking && !state.isLoading)
                        Expanded(
                          child: _DailySummaryCard(
                            distanceKm: _frozenApiDistance + state.distanceKm,
                            unit: 'activity_tracking.km_unit'.tr(),
                            minutes: _frozenApiDurationMinutes + state.activeMinutes,
                            calories: _frozenApiCalories + state.caloriesKcal.round(),
                            isWalking: true,
                          ),
                        )
                      else
                        const Spacer(),

                      _StartStopButton(
                        isRunning: state.isTracking,
                        onTap: () =>
                            _onToggleTracking(context, state.isTracking),
                      ),
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

// ═════════════════════════════════════════════════════════════════════════════
// RUNNING SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class _RunningScreen extends StatefulWidget {
  final double apiProgress;
  final int apiProgressPercent;
  final int apiDurationMinutes;
  final double apiCalories;
  final ActivityDetailsCubit activityCubit;

  const _RunningScreen({
    this.apiProgress = 0,
    this.apiProgressPercent = 0,
    this.apiDurationMinutes = 0,
    this.apiCalories = 0,
    required this.activityCubit,
  });

  @override
  State<_RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<_RunningScreen> {
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

  List<String> get _tabs => [
        'activity_tracking.tab_daily'.tr(),
        'activity_tracking.tab_weekly'.tr(),
      ];

  @override
  void initState() {
    super.initState();
    _frozenApiProgress = _runningProgressKm(widget.apiProgress);
    _frozenApiProgressPct = widget.apiProgressPercent;
    _frozenApiGoal = 0;
    _frozenApiUnit = 'activity_tracking.km_unit'.tr();
    _frozenActivityName = 'activity_tracking.running_title'.tr();
    _frozenApiDuration = widget.apiDurationMinutes;
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
    _frozenApiProgress = _runningProgressKm(data.currentProgress);
    _frozenApiProgressPct = data.progressPercentage.toInt();
    _frozenApiGoal = _runningGoalKm(data.goal);
    _frozenApiUnit = data.unit.isNotEmpty ? data.unit : 'activity_tracking.km_unit'.tr();
    _frozenActivityName = data.name.isNotEmpty ? data.name : 'activity_tracking.running_title'.tr();
    _frozenApiDuration = data.durationMinutes?.toInt() ?? 0;
    _frozenApiCalories = data.caloriesBurned ?? 0;
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
      _refreshDetails();
      return;
    }
    await cubit.startSession();
  }

  /// Read-only weekly aggregate — distance + summary straight from the API,
  /// with no live run and no start/stop button.
  Widget _buildWeeklyView() {
    final data = _weeklyData;
    final double km = data != null ? _runningProgressKm(data.currentProgress) : 0;
    final double goal = data != null ? _runningGoalKm(data.goal) : 0;
    final String unit = (data?.unit.isNotEmpty ?? false)
        ? data!.unit
        : 'activity_tracking.km_unit'.tr();
    final double percent = goal > 0
        ? (km / goal).clamp(0.0, 1.0)
        : (data != null ? (data.progressPercentage / 100).clamp(0.0, 1.0) : 0.0);

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, _frozenActivityName),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: _PeriodTabBar(
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
                _ActivityCircle(
                  percent: percent,
                  currentVal: km,
                  goalVal: goal,
                  unit: unit,
                  goalPercent: (percent * 100).round(),
                  decimals: 2,
                ),
                SizedBox(height: 32.h),
                Expanded(
                  child: _DailySummaryCard(
                    title: 'activity_tracking.week_summary'.tr(),
                    distanceKm: km,
                    unit: unit,
                    minutes: data.durationMinutes?.toInt() ?? 0,
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
            final bool showLive = _selectedTab == 0 && state.distanceKm > 0;

            // The run adds to the day's total rather than replacing it: the
            // circle showed only the current session's distance, so a user who
            // had already covered ground saw the number collapse on start.
            final double totalKm =
                _frozenApiProgress + (showLive ? state.distanceKm : 0);
            final double totalPercent = _frozenApiGoal > 0
                ? (totalKm / _frozenApiGoal).clamp(0.0, 1.0)
                : (_frozenApiProgressPct / 100.0).clamp(0.0, 1.0);

            return Scaffold(
              body: ScreenBackground(
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(context, _frozenActivityName),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: _PeriodTabBar(
                          tabs: _tabs,
                          selectedIndex: _selectedTab,
                          onTabChanged: _onTabChanged,
                        ),
                      ),
                      SizedBox(height: 40.h),

                      if (!state.permissionGranted)
                        _PermissionBanner(
                          message: 'activity_tracking.needs_location_motion'.tr(),
                          onTap: () =>
                              context.read<RunningCubit>().requestPermissions(),
                        )
                      else ...[
                        _ActivityCircle(
                          percent: totalPercent,
                          currentVal: totalKm,
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
                          child: _DailySummaryCard(
                            distanceKm: totalKm,
                            unit: _frozenApiUnit,
                            minutes: _frozenApiDuration +
                                (showLive ? state.elapsedSeconds ~/ 60 : 0),
                            calories: state.caloriesKcal > 0
                                ? state.caloriesKcal.round()
                                : _frozenApiCalories.round(),
                            isWalking: false,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        _StartStopButton(
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared app bar builder
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildAppBar(BuildContext context, String title) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new,
              size: 20.sp, color: AppColors.black),
        ),
        const Spacer(),
        Text(
          title,
          style: TextStyleManager.heading2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        const Spacer(),
        SizedBox(width: 20.sp),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Period Tab Bar
// ─────────────────────────────────────────────────────────────────────────────

class _PeriodTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const _PeriodTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final bool sel = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xffDEF4E1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                  border:
                      sel ? Border.all(color: AppColors.divider) : null,
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.09),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: sel ? AppColors.primary : AppColors.black,
                    fontWeight:
                        sel ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity Circle (shared between walking & running)
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityCircle extends StatelessWidget {
  final double percent;
  final double currentVal;
  final double goalVal;
  final String unit;
  final int goalPercent;

  /// Decimal places for the values — distances read as 1.25, steps as 1250.
  final int decimals;

  const _ActivityCircle({
    required this.percent,
    required this.currentVal,
    required this.goalVal,
    required this.unit,
    required this.goalPercent,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            CircularPercentIndicator(
              radius: 115.r,
              lineWidth: 16.w,
              percent: percent,
              startAngle: 220,
              backgroundColor: AppColors.backgroundTint,
              progressColor: AppColors.greenLightAccent,
              circularStrokeCap: CircularStrokeCap.round,
              // Fixed size, not padding-driven: sizing the inner disc from its
              // text made the whole circle swell and shrink as the step count
              // gained or lost digits. The values scale down to fit instead.
              center: Container(
                width: _kInnerDiscSize,
                height: _kInnerDiscSize,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundTint,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // A play/pause badge used to sit between these two, but it
                    // was driven by the activity type rather than the session
                    // and had no tap handler — a control that could never do
                    // anything. Running has a real start/stop button below.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currentVal.toStringAsFixed(decimals),
                        maxLines: 1,
                        style: TextStyleManager.style28Bold
                            .copyWith(color: AppColors.black),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '/ ${goalVal.toStringAsFixed(decimals)} $unit',
                        maxLines: 1,
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.greenMint, width: 1.r),
                    gradient: AppColors.timeRemainingGradient,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'activity_tracking.goal_percent'
                        .tr(args: ['$goalPercent']),
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.greenDarkAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class _DailySummaryCard extends StatelessWidget {
  final double distanceKm;
  final String unit;
  final int minutes;
  final int calories;
  final bool isWalking;

  /// Heading above the card. Defaults to the daily label; the weekly view
  /// passes its own so the same card serves both periods.
  final String? title;

  const _DailySummaryCard({
    required this.distanceKm,
    required this.unit,
    required this.minutes,
    required this.calories,
    this.isWalking = false,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? 'activity_tracking.day_summary'.tr(),
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 19.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.borderGrey),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryItem(
                  icon: const Icon(Icons.local_fire_department_rounded,
                      color: Colors.deepOrangeAccent, size: 26),
                  label: 'activity_tracking.calories_label'.tr(),
                  value: '$calories',
                  unit: 'activity_tracking.calorie_unit'.tr(),
                ),
                _SummaryItem(
                  icon: Icon(Icons.access_time_filled_rounded,
                      color: AppColors.surfaceGray, size: 26),
                  label: 'activity_tracking.elapsed_time'.tr(),
                  value: '$minutes',
                  unit: 'activity_tracking.minute_unit'.tr(),
                ),
                _SummaryItem(
                  icon: const Icon(Icons.location_on_rounded,
                      color: Colors.pinkAccent, size: 26),
                  label: 'activity_tracking.distance_label'.tr(),
                  value: distanceKm.toStringAsFixed(2),
                  unit: unit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Start / Stop Button (Running only)
// ─────────────────────────────────────────────────────────────────────────────

class _StartStopButton extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onTap;

  const _StartStopButton({required this.isRunning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRunning ? Colors.red.shade400 : AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: (isRunning ? Colors.red : AppColors.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 36.sp,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Permission Banner
// ─────────────────────────────────────────────────────────────────────────────

class _PermissionBanner extends StatelessWidget {
  final String message;
  final VoidCallback onTap;

  const _PermissionBanner({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.health_and_safety_outlined,
                color: AppColors.primary, size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(message,
                  style: TextStyleManager.style11Medium
                      .copyWith(color: AppColors.black)),
            ),
            TextButton(
              onPressed: onTap,
              child: Text('activity_tracking.allow'.tr(),
                  style: TextStyleManager.style11Medium
                      .copyWith(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Item
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final String unit;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyleManager.dataCard.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 4.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyleManager.style16Bold
                    .copyWith(color: AppColors.primary),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyleManager.heading2.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
