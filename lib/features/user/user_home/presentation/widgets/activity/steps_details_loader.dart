import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/activity_details_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/activity_details_state.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/running_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/walking_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/activity_type.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/activity_duration.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/running_screen.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/walking_screen.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';

/// Waits for [ActivityDetailsCubit] to load once, then keeps the screen alive
/// while subsequent period-switch calls run in the background.
class StepsDetailsLoader extends StatefulWidget {
  final ActivityType type;
  final String assessmentId;
  final int dayNumber;
  final String activityId;

  const StepsDetailsLoader({
    super.key,
    required this.type,
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
  });

  @override
  State<StepsDetailsLoader> createState() => _StepsDetailsLoaderState();
}

class _StepsDetailsLoaderState extends State<StepsDetailsLoader> {
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
        syncRunningUseCase: getIt(),
        assessmentId: widget.assessmentId,
        dayNumber: widget.dayNumber,
        activityId: widget.activityId,
        activityItemId: data.activityItemId,
        // Already kilometres on both sides — no conversion.
        goalDistanceKm: data.goal,
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
        syncWalkingUseCase: getIt(),
        assessmentId: widget.assessmentId,
        dayNumber: widget.dayNumber,
        activityId: widget.activityId,
        activityItemId: data.activityItemId,
        goalSteps: data.goal,
        // The API goal for walking is a step count; there is no distance
        // target, so don't pass the step goal as one.
        goalDistanceKm: 0,
      );
      // Check if permissions are already granted so the banner doesn't show
      // unnecessarily when the user reopens the screen.
      _walkingCubit!.refreshPermissionStatus();
    }
  }

  /// Returns true if a walking or running session is currently active.
  bool _isSessionActive() {
    if (_walkingCubit != null) return _walkingCubit!.state.isTracking;
    if (_runningCubit != null) return _runningCubit!.state.isRunning;
    return false;
  }

  /// Closes an in-flight session before the screen goes away.
  ///
  /// Leaving mid-session used to rely on `close()` (via [dispose]) to fire the
  /// final sync, and `dispose` cannot await — so the POST was still in flight
  /// while the screen underneath refetched, and that refetch read pre-sync
  /// figures. Stopping here means the sync has landed by the time we pop.
  ///
  /// The re-read afterwards is what tells the screens underneath about the walk.
  /// Pressing Stop refreshes on its own, so this path only runs when the user
  /// backs out mid-session — and it is a single GET whose result reaches the
  /// home and today-tasks cards through [ActivityDetailsCubit]'s publish to
  /// `AppEventBus`, replacing the two-request home refetch that used to run
  /// on every return regardless.
  Future<void> _finishSessionBeforeLeaving(
    ActivityDetailsCubit activityCubit,
  ) async {
    if (_walkingCubit != null && _walkingCubit!.state.isTracking) {
      await _walkingCubit!.stopTracking();
    }
    if (_runningCubit != null && _runningCubit!.state.isRunning) {
      await _runningCubit!.stopSession();
    }
    if (!mounted) return;
    // Daily explicitly: the user may have left the weekly tab selected, and the
    // cards behind this screen are about today.
    await activityCubit.getActivityDetails(
      activityCubit.assessmentId,
      activityCubit.dayNumber,
      activityCubit.activityId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Always false rather than `!_isSessionActive()`: this widget
      // deliberately does not rebuild while a session runs (see buildWhen
      // below), so a session-dependent value here would be read stale and the
      // pop would slip past the guard. The handler fast-paths when there is no
      // session, so the cost is a single frame.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // Resolved before the await so neither reaches for a context that may
        // have gone away while the final sync was in flight.
        final NavigatorState navigator = Navigator.of(context);
        final ActivityDetailsCubit activityCubit = context
            .read<ActivityDetailsCubit>();
        if (_isSessionActive()) {
          await _finishSessionBeforeLeaving(activityCubit);
        }
        if (!mounted) return;
        navigator.pop();
      },
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
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
        if ((state is ActivityDetailsLoading ||
                state is ActivityDetailsInitial) &&
            !_initialized) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ActivityDetailsFailure && !_initialized) {
          // Retry rather than "back": the screen never loaded, and leaving is
          // something the system back gesture already offers.
          return Scaffold(
            backgroundColor: AppColors.white,
            body: AppErrorView(
              error: state.error,
              message: state.message,
              onRetry: () =>
                  context.read<ActivityDetailsCubit>().getActivityDetails(
                    widget.assessmentId,
                    widget.dayNumber,
                    widget.activityId,
                  ),
            ),
          );
        }

        // Use fresh data or cached data
        final data =
            (state is ActivityDetailsSuccess ? state.data : null) ??
            _cachedData;
        if (data == null) return const SizedBox.shrink();

        final double currentProgress = data.currentProgress;
        final int progressPercent = data.progressPercentage.toInt();
        final activityCubit = context.read<ActivityDetailsCubit>();

        if (widget.type == ActivityType.walking) {
          if (_walkingCubit == null) return const SizedBox.shrink();
          return BlocProvider.value(
            value: _walkingCubit!,
            child: WalkingScreen(
              apiProgress: currentProgress,
              apiProgressPercent: progressPercent,
              activityCubit: activityCubit,
            ),
          );
        } else {
          if (_runningCubit == null) return const SizedBox.shrink();
          return BlocProvider.value(
            value: _runningCubit!,
            child: RunningScreen(
              apiProgress: currentProgress,
              apiProgressPercent: progressPercent,
              apiDurationSeconds: apiDurationSeconds(data.durationMinutes),
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
