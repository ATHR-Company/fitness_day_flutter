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
      // Don't call requestPermissions() automatically — user triggers it
    }
    // WalkingCubit is NOT created here — it's only created when user
    // explicitly taps the "enable live tracking" banner
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityDetailsCubit, ActivityDetailsState>(
      listener: (context, state) {
        if (state is ActivityDetailsSuccess) {
          _initActivityCubits(state.data);
          setState(() => _cachedData = state.data);
        }
      },
      // Only rebuild on the very first load or failure — not on subsequent loading
      buildWhen: (prev, curr) {
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
                    child: const Text('رجوع'),
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
          // Walking screen uses API data by default.
          // WalkingCubit is created lazily only if user taps "enable live tracking"
          if (_walkingCubit == null) {
            return _WalkingScreen(
              apiProgress: currentProgress,
              apiProgressPercent: progressPercent,
              activityCubit: activityCubit,
              onEnableLiveTracking: () {
                setState(() {
                  _walkingCubit = WalkingCubit(
                    healthService: getIt(),
                    apiService: getIt(),
                    storage: getIt(),
                    assessmentId: widget.assessmentId,
                    dayNumber: widget.dayNumber,
                    activityId: widget.activityId,
                    activityItemId: data.activityItemId,
                    goalSteps: data.goal,
                    goalDistanceKm: data.goal,
                  )..init();
                });
              },
            );
          }
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
  final VoidCallback? onEnableLiveTracking;

  const _WalkingScreen({
    this.apiProgress = 0,
    this.apiProgressPercent = 0,
    required this.activityCubit,
    this.onEnableLiveTracking,
  });

  @override
  State<_WalkingScreen> createState() => _WalkingScreenState();
}

class _WalkingScreenState extends State<_WalkingScreen>
    with WidgetsBindingObserver {
  int _selectedTab = 0;
  final List<String> _tabs = ['يومي', 'أسبوعي'];

  void _onTabChanged(int index, BuildContext context) {
    setState(() => _selectedTab = index);
    final period = index == 0 ? 'daily' : 'weekly';
    widget.activityCubit.getActivityDetails(
      widget.activityCubit.assessmentId,
      widget.activityCubit.dayNumber,
      widget.activityCubit.activityId,
      period: period,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only interact with WalkingCubit if it's available in context
    try {
      final cubit = context.read<WalkingCubit>();
      if (state == AppLifecycleState.resumed) {
        cubit.resumeTracking();
      } else if (state == AppLifecycleState.paused) {
        cubit.pauseTracking();
      }
    } catch (_) {
      // WalkingCubit not in context yet — live tracking not enabled
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if WalkingCubit is available (live tracking enabled)
    WalkingCubit? walkingCubit;
    try {
      walkingCubit = context.read<WalkingCubit>();
    } catch (_) {}

    if (walkingCubit == null) {
      // API-only mode — listen to ActivityDetailsCubit for live updates
      return BlocBuilder<ActivityDetailsCubit, ActivityDetailsState>(
        bloc: widget.activityCubit,
        builder: (context, actState) {
          final data = actState is ActivityDetailsSuccess ? actState.data : null;
          final double progress = data?.currentProgress ?? widget.apiProgress;
          final int progressPct = data?.progressPercentage.toInt() ?? widget.apiProgressPercent;
          final double goal = data?.goal ?? 0;
          final String unit = data?.unit ?? 'خطوة';

          return Scaffold(
            body: ScreenBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context, data?.name ?? 'تتبع الخطوات'),
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
                      percent: (progressPct / 100.0).clamp(0.0, 1.0),
                      currentVal: progress,
                      goalVal: goal,
                      unit: unit,
                      goalPercent: progressPct,
                      isRunning: false,
                    ),
                    SizedBox(height: 32.h),
                    if (widget.onEnableLiveTracking != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _PermissionBanner(
                          message: 'اضغط لتفعيل تتبع الخطوات الحي',
                          onTap: widget.onEnableLiveTracking!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return BlocBuilder<ActivityDetailsCubit, ActivityDetailsState>(
      bloc: widget.activityCubit,
      builder: (context, actState) {
        final actData = actState is ActivityDetailsSuccess ? actState.data : null;
        final double apiProgress = actData?.currentProgress ?? widget.apiProgress;
        final int apiProgressPct = actData?.progressPercentage.toInt() ?? widget.apiProgressPercent;
        final double apiGoal = actData?.goal ?? 0;
        final String apiUnit = actData?.unit ?? 'خطوة';

        return BlocBuilder<WalkingCubit, WalkingState>(
          builder: (context, state) {
            return Scaffold(
              body: ScreenBackground(
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(context, actData?.name ?? 'تتبع الخطوات'),
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
                        percent: state.steps > 0
                            ? state.progressPercent
                            : (apiProgressPct / 100.0).clamp(0.0, 1.0),
                        currentVal: state.steps > 0
                            ? state.steps.toDouble()
                            : apiProgress,
                        goalVal: state.steps > 0 ? state.goalSteps : apiGoal,
                        unit: apiUnit,
                        goalPercent: state.steps > 0
                            ? state.progressPercentInt
                            : apiProgressPct,
                        isRunning: false,
                      ),
                      SizedBox(height: 32.h),
                      if (state.permissionStatus == HealthPermStatus.needsInstall)
                        _PermissionBanner(
                          message: 'لتفعيل التتبع الحي — ثبّت Health Connect من Play Store',
                          onTap: () => context.read<WalkingCubit>().init(),
                        )
                      else if (state.permissionStatus == HealthPermStatus.denied)
                        _PermissionBanner(
                          message: 'لتفعيل التتبع الحي — اسمح بالوصول لبيانات الصحة',
                          onTap: () => context.read<WalkingCubit>().init(),
                        )
                      else if (state.permissionStatus == HealthPermStatus.granted &&
                          !state.isLoading)
                        Expanded(
                          child: _DailySummaryCard(
                            distanceKm: state.distanceKm,
                            unit: 'كم',
                            minutes: state.activeMinutes,
                            calories: state.caloriesKcal.round(),
                            isWalking: true,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
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
  final List<String> _tabs = ['يومي', 'أسبوعي'];

  void _onTabChanged(int index) {
    setState(() => _selectedTab = index);
    final period = index == 0 ? 'daily' : 'weekly';
    widget.activityCubit.getActivityDetails(
      widget.activityCubit.assessmentId,
      widget.activityCubit.dayNumber,
      widget.activityCubit.activityId,
      period: period,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityDetailsCubit, ActivityDetailsState>(
      bloc: widget.activityCubit,
      builder: (context, actState) {
        final actData = actState is ActivityDetailsSuccess ? actState.data : null;
        final double apiProgress = actData?.currentProgress ?? widget.apiProgress;
        final int apiProgressPct = actData?.progressPercentage.toInt() ?? widget.apiProgressPercent;
        final double apiGoal = actData != null
            ? _runningGoalKm(actData.goal)
            : widget.apiProgress;
        final String apiUnit = actData?.unit ?? 'كم';
        final int apiDuration = actData?.durationMinutes?.toInt() ?? widget.apiDurationMinutes;
        final double apiCalories = actData?.caloriesBurned ?? widget.apiCalories;

        return BlocBuilder<RunningCubit, RunningState>(
          builder: (context, state) {
            return Scaffold(
              body: ScreenBackground(
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(context, actData?.name ?? 'تتبع الجري'),
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
                          message: 'يحتاج إذن الموقع والحركة',
                          onTap: () =>
                              context.read<RunningCubit>().requestPermissions(),
                        )
                      else ...[
                        _ActivityCircle(
                          percent: state.distanceKm > 0
                              ? state.progressPercent
                              : (apiProgressPct / 100.0).clamp(0.0, 1.0),
                          currentVal: state.distanceKm > 0
                              ? state.distanceKm
                              : apiProgress,
                          goalVal: state.distanceKm > 0
                              ? state.goalDistanceKm
                              : apiGoal,
                          unit: apiUnit,
                          goalPercent: state.distanceKm > 0
                              ? state.progressPercentInt
                              : apiProgressPct,
                          isRunning: true,
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
                          'الوقت المستغرق',
                          style: TextStyleManager.style11Medium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        SizedBox(height: 24.h),

                        Expanded(
                          child: _DailySummaryCard(
                            distanceKm: state.isRunning || state.distanceKm > 0
                                ? state.distanceKm
                                : apiProgress,
                            unit: apiUnit,
                            minutes: state.isRunning || state.elapsedSeconds > 0
                                ? state.elapsedSeconds ~/ 60
                                : apiDuration,
                            calories: state.isRunning || state.caloriesKcal > 0
                                ? state.caloriesKcal.round()
                                : apiCalories.round(),
                            isWalking: false,
                            pace: state.pace,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        _StartStopButton(
                          isRunning: state.isRunning,
                          onTap: () {
                            if (state.isRunning) {
                              context.read<RunningCubit>().stopSession();
                            } else {
                              context.read<RunningCubit>().startSession();
                            }
                          },
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
  final bool isRunning;

  const _ActivityCircle({
    required this.percent,
    required this.currentVal,
    required this.goalVal,
    required this.unit,
    required this.goalPercent,
    required this.isRunning,
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
              center: Container(
                padding: isRunning
                    ? EdgeInsets.all(55.w)
                    : EdgeInsets.all(45.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundTint,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isRunning
                          ? currentVal.toStringAsFixed(2)
                          : currentVal.toStringAsFixed(0),
                      style: TextStyleManager.style28Bold
                          .copyWith(color: AppColors.black),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isRunning
                            ? Icons.pause
                            : Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '/ ${isRunning ? goalVal.toStringAsFixed(2) : goalVal.toStringAsFixed(0)} $unit',
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.textSecondary,
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
                    '$goalPercent% من هدفك',
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
  final String? pace;

  const _DailySummaryCard({
    required this.distanceKm,
    required this.unit,
    required this.minutes,
    required this.calories,
    this.isWalking = false,
    this.pace,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص اليوم',
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
                  label: 'عدد السعرات',
                  value: '$calories',
                  unit: 'كالوري',
                ),
                _SummaryItem(
                  icon: Icon(Icons.access_time_filled_rounded,
                      color: AppColors.surfaceGray, size: 26),
                  label: pace != null ? 'البيس' : 'الوقت المستغرق',
                  value: pace ?? '$minutes',
                  unit: pace != null ? 'دق/كم' : 'دقيقة',
                ),
                _SummaryItem(
                  icon: const Icon(Icons.location_on_rounded,
                      color: Colors.pinkAccent, size: 26),
                  label: 'المسافة',
                  value: isWalking
                      ? distanceKm.toStringAsFixed(2)
                      : distanceKm.toStringAsFixed(2),
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
              child: Text('السماح',
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
