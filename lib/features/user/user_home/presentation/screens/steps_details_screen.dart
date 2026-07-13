import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
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
      child: _StepsDetailsLoader(type: type),
    );
  }
}

/// Waits for [ActivityDetailsCubit] to load, then shows the appropriate screen.
class _StepsDetailsLoader extends StatelessWidget {
  final ActivityType type;
  const _StepsDetailsLoader({required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityDetailsCubit, ActivityDetailsState>(
      builder: (context, state) {
        if (state is ActivityDetailsLoading ||
            state is ActivityDetailsInitial) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ActivityDetailsFailure) {
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

        // Success — extract goal from API response
        final data =
            state is ActivityDetailsSuccess ? state.data : null;
        final double goalSteps = data?.goal ?? 5000;
        final double goalDistanceKm = data?.goal ?? 5.0;
        final double currentProgress = data?.currentProgress ?? 0;
        final int progressPercent = data?.progressPercentage.toInt() ?? 0;

        if (type == ActivityType.walking) {
          return BlocProvider(
            create: (_) => WalkingCubit(
              healthService: getIt(),
              apiService: getIt(),
              goalSteps: goalSteps,
              goalDistanceKm: goalDistanceKm,
            )..init(),
            child: _WalkingScreen(
              apiProgress: currentProgress,
              apiProgressPercent: progressPercent,
            ),
          );
        } else {
          final double apiDistanceKm = data?.currentProgress ?? 0;
          final int apiDurationMinutes = data?.durationMinutes?.toInt() ?? 0;
          final double apiCalories = data?.caloriesBurned ?? 0;

          return BlocProvider(
            create: (_) => RunningCubit(
              apiService: getIt(),
              goalDistanceKm: goalDistanceKm,
            )..requestPermissions(),
            child: _RunningScreen(
              apiProgress: apiDistanceKm,
              apiProgressPercent: progressPercent,
              apiDurationMinutes: apiDurationMinutes,
              apiCalories: apiCalories,
            ),
          );
        }
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WALKING SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class _WalkingScreen extends StatefulWidget {
  final double apiProgress;
  final int apiProgressPercent;

  const _WalkingScreen({
    this.apiProgress = 0,
    this.apiProgressPercent = 0,
  });

  @override
  State<_WalkingScreen> createState() => _WalkingScreenState();
}

class _WalkingScreenState extends State<_WalkingScreen>
    with WidgetsBindingObserver {
  int _selectedTab = 0;
  final List<String> _tabs = ['يومي', 'أسبوعي'];

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
    final cubit = context.read<WalkingCubit>();
    if (state == AppLifecycleState.resumed) {
      cubit.resumeTracking();
    } else if (state == AppLifecycleState.paused) {
      cubit.pauseTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalkingCubit, WalkingState>(
      builder: (context, state) {
        return Scaffold(
          body: ScreenBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, 'تتبع الخطوات'),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: _PeriodTabBar(
                      tabs: _tabs,
                      selectedIndex: _selectedTab,
                      onTabChanged: (i) => setState(() => _selectedTab = i),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Show API data immediately — Health Connect is optional for live tracking
                  _ActivityCircle(
                    percent: state.steps > 0
                        ? state.progressPercent
                        : (widget.apiProgressPercent / 100.0).clamp(0.0, 1.0),
                    currentVal: state.steps > 0
                        ? state.steps.toDouble()
                        : widget.apiProgress,
                    goalVal: state.goalSteps,
                    unit: 'خطوة',
                    goalPercent: state.steps > 0
                        ? state.progressPercentInt
                        : widget.apiProgressPercent,
                    isRunning: false,
                  ),
                  SizedBox(height: 32.h),

                  // Optional live-tracking banner
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
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// RUNNING SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class _RunningScreen extends StatelessWidget {
  final double apiProgress;
  final int apiProgressPercent;
  final int apiDurationMinutes;
  final double apiCalories;

  const _RunningScreen({
    this.apiProgress = 0,
    this.apiProgressPercent = 0,
    this.apiDurationMinutes = 0,
    this.apiCalories = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RunningCubit, RunningState>(
      builder: (context, state) {
        return Scaffold(
          body: ScreenBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, 'تتبع الجري'),
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
                          : (apiProgressPercent / 100.0).clamp(0.0, 1.0),
                      currentVal: state.distanceKm > 0
                          ? state.distanceKm
                          : apiProgress,
                      goalVal: state.goalDistanceKm,
                      unit: 'كم',
                      goalPercent: state.distanceKm > 0
                          ? state.progressPercentInt
                          : apiProgressPercent,
                      isRunning: true,
                    ),
                    SizedBox(height: 16.h),

                    // Elapsed time
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
                        unit: 'كم',
                        minutes: state.isRunning || state.elapsedSeconds > 0
                            ? state.elapsedSeconds ~/ 60
                            : apiDurationMinutes,
                        calories: state.isRunning || state.caloriesKcal > 0
                            ? state.caloriesKcal.round()
                            : apiCalories.round(),
                        isWalking: false,
                        pace: state.pace,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Start / Stop button
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
