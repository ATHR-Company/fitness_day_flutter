import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/core/services/app_share_service.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/domain/usecases/challenges_usecases.dart';
import 'package:fitness_day/features/user/challenges/presentation/dialogs/leave_challenge_dialog.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/activity_sync_service.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/challenges_events.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_app_bar.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_header_info.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_hero_section.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_options_sheet.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_previous_achievements.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_progress_content.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/running_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/walking_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/permission_banner.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/hydration/manual_add_sheet.dart';

// ─── Challenge Type ───────────────────────────────────────────────────────────

/// Which body the active-challenge screen shows.
///
/// Derived from the challenge's own metric rather than passed in by whoever
/// opens the screen — the server decides what a challenge measures, and a
/// caller guessing it would put a step counter on a hydration challenge.
enum ChallengeType {
  /// Steps — walking sensors.
  steps,

  /// Distance or calories. Both are earned by moving and both are tracked with
  /// the running session, by product decision — GPS is what measures them.
  exercise,

  /// Water, in millilitres. Logged by hand, not sensed.
  hydration;

  static ChallengeType fromMetric(ChallengeMetric? metric) => switch (metric) {
        ChallengeMetric.steps => ChallengeType.steps,
        ChallengeMetric.waterMl => ChallengeType.hydration,
        // Distance and calories both go to running. An unknown metric lands
        // here too: the generic body shows progress against the goal without
        // claiming to know how it is earned.
        _ => ChallengeType.exercise,
      };
}

// ─── Screen ───────────────────────────────────────────────────────────────────

/// The challenge itself: progress, and the session that moves it.
///
/// This is the **plan-free** tracking entry point. The walking and running
/// cubits are built with empty plan ids on purpose — with no `activityItemId`
/// they skip the plan's own sync entirely and feed only `POST /activity-sync`,
/// which is open to every signed-in user. So a user with no subscription and no
/// assessment can still move a challenge.
///
/// A session runs only while this screen is on top: it starts on the play
/// button and is stopped before the screen is popped. Nothing is counted in the
/// background, which is what keeps a challenge honest.
class ChallengeActiveScreen extends StatefulWidget {
  final ChallengeModel challenge;

  const ChallengeActiveScreen({super.key, required this.challenge});

  @override
  State<ChallengeActiveScreen> createState() => _ChallengeActiveScreenState();
}

class _ChallengeActiveScreenState extends State<ChallengeActiveScreen> {
  /// Replaced wholesale whenever a sync reports this challenge, so progress,
  /// completion and participant count all stay the server's.
  late ChallengeModel _challenge;

  StreamSubscription<AppEvent>? _ledgerSub;

  WalkingCubit? _walking;
  RunningCubit? _running;

  /// Server progress as it stood when the session started.
  ///
  /// The ring shows `baseline + session`, and the session counter is relative
  /// to its own start — so the baseline must not move while a session runs, or
  /// the sync that lands mid-session would be added on top of steps it already
  /// contains. Null means no session, and the ring is purely the server's.
  double? _sessionBaseline;

  ChallengeType get _type => ChallengeType.fromMetric(_challenge.metric);

  /// Whether a session produces a number this screen can add locally.
  ///
  /// Steps and distance are measured on the device. Calories are not: the
  /// backend computes them from distance and the user's profile weight, and the
  /// running cubit only ever learns them from the *plan's* sync response, which
  /// does not run here. Water is typed in, not sensed. For those two the ring
  /// stays server-authoritative and moves when the sync answers.
  bool get _hasLiveDelta =>
      _challenge.metric == ChallengeMetric.steps ||
      _challenge.metric == ChallengeMetric.distanceKm;

  @override
  void initState() {
    super.initState();
    _challenge = widget.challenge;

    switch (_type) {
      case ChallengeType.steps:
        _walking = WalkingCubit(
          healthService: getIt(),
          syncWalkingUseCase: getIt(),
          activitySyncService: getIt(),
          // Empty on purpose — see the class doc. These are the plan's
          // coordinates, and this screen has no plan.
          assessmentId: '',
          dayNumber: 0,
          activityId: '',
          activityItemId: '',
          goalSteps: _challenge.goal,
          goalDistanceKm: 0,
        )..refreshPermissionStatus();
      case ChallengeType.exercise:
        _running = RunningCubit(
          syncRunningUseCase: getIt(),
          activitySyncService: getIt(),
          assessmentId: '',
          dayNumber: 0,
          activityId: '',
          activityItemId: '',
          goalDistanceKm: _challenge.goal,
        )..refreshPermissionStatus();
      case ChallengeType.hydration:
        break;
    }

    _ledgerSub = getIt<AppEventBus>().stream.listen((event) {
      if (event is! ActivityLedgerChanged || !mounted) return;
      for (final c in event.challenges) {
        if (c.id != _challenge.id) continue;
        // Patched, not replaced: the sync entry has no dates, participant count
        // or `isJoined`, so assigning it wholesale blanked the header of the
        // very screen the session was started from.
        setState(() => _challenge = _challenge.withLedgerProgress(c));
        break;
      }
    });
  }

  @override
  void dispose() {
    _ledgerSub?.cancel();
    // Both close() implementations fire a final sync when a session is still
    // open, so nothing walked is lost even on an abrupt teardown.
    _walking?.close();
    _running?.close();
    super.dispose();
  }

  bool get _isTracking =>
      (_walking?.state.isTracking ?? false) ||
      (_running?.state.isRunning ?? false);

  Future<void> _toggleSession() async {
    if (_type == ChallengeType.hydration) {
      await _logWater();
      return;
    }

    if (_isTracking) {
      await _stopSession();
      return;
    }

    // Freeze before starting: the session counts from zero, so the ring adds it
    // to where the server already was.
    setState(() => _sessionBaseline = _hasLiveDelta ? _challenge.progress : null);

    if (_walking != null) {
      await _walking!.startTracking();
    } else if (_running != null) {
      await _running!.startSession(context);
    }
    if (!mounted) return;

    // Permission refused — nothing is running, so drop the baseline again.
    if (!_isTracking) setState(() => _sessionBaseline = null);
    setState(() {});
  }

  Future<void> _stopSession() async {
    if (_walking?.state.isTracking ?? false) await _walking!.stopTracking();
    if (_running?.state.isRunning ?? false) await _running!.stopSession();
    if (!mounted) return;
    // The final sync's response comes back through the ledger event and
    // replaces `_challenge`, so the baseline hands the ring back to the server.
    setState(() => _sessionBaseline = null);
  }

  /// Water is entered, not measured, so it has no session — each confirmation
  /// is one delta.
  Future<void> _logWater() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ManualAddSheet(
        onConfirm: (litres) {
          // The sheet deals in litres; the ledger takes millilitres.
          getIt<ActivitySyncService>()
              .pushHydration(deltaWaterMl: (litres * 1000).round());
        },
      ),
    );
  }

  /// Leaving discards progress outright, so it asks first.
  Future<void> _leaveChallenge() async {
    final navigator = Navigator.of(context);
    final bool confirmed = await confirmLeaveChallenge(context);
    if (!confirmed || !mounted) return;

    await _stopSession();
    final result = await getIt<LeaveChallengeUseCase>()(_challenge.id);
    if (!mounted) return;

    switch (result) {
      case Success():
        navigator.pop();
      case FailureResult(:final failure):
        showAppSnackBar(context, text: failure.message, isError: true);
    }
  }

  void _showOptionsSheet(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.black.withValues(alpha: 0.25),
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 24.h),
        backgroundColor: Colors.transparent,
        child: ChallengeOptionsSheet(
          onEndChallenge: _leaveChallenge,
          onShare: () => AppShareService.shareChallenge(
            context,
            challengeName: _challenge.name,
          ),
        ),
      ),
    );
  }

  double get _displayProgress {
    final baseline = _sessionBaseline;
    if (baseline == null) return _challenge.progress;
    return baseline + _sessionDelta;
  }

  double get _sessionDelta => switch (_challenge.metric) {
        ChallengeMetric.steps => _walking?.state.steps.toDouble() ?? 0,
        ChallengeMetric.distanceKm => _running?.state.distanceKm ?? 0,
        _ => 0,
      };

  /// One fraction for the whole screen, so the badge over the image and the
  /// ring underneath can never disagree.
  double get _displayFraction => _challenge.goal > 0
      ? (_displayProgress / _challenge.goal).clamp(0.0, 1.0)
      : _challenge.progressFraction;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Always false: the session has to be stopped and its last delta flushed
      // before the screen goes away, and that cannot be awaited once the pop
      // has already happened.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (_isTracking) await _stopSession();
        if (!mounted) return;
        navigator.pop();
      },
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    // Rebuild on every sensor tick so the ring and the clock move with the
    // session rather than only when a sync answers.
    if (_walking != null) {
      return BlocBuilder<WalkingCubit, WalkingState>(
        bloc: _walking,
        builder: (context, _) => _buildBody(),
      );
    }
    if (_running != null) {
      return BlocBuilder<RunningCubit, RunningState>(
        bloc: _running,
        builder: (context, _) => _buildBody(),
      );
    }
    return _buildBody();
  }

  Widget _buildBody() {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ChallengeAppBar(
                title: 'challenges.details_title'.tr(),
                trailing: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showOptionsSheet(context),
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(Icons.more_vert_rounded,
                        size: 22.sp, color: AppColors.black),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ChallengeHeroSection(
                        imageUrl: _challenge.image,
                        achievedPercent: (_displayFraction * 100).round(),
                      ),
                      SizedBox(height: 24.h),
                      ChallengeHeaderInfo(challenge: _challenge),
                      SizedBox(height: 24.h),
                      if (_permissionBanner case final banner?) ...[
                        banner,
                        SizedBox(height: 16.h),
                      ],
                      // One ring for every metric. It reads progress, goal and
                      // unit off the challenge, so steps, kilometres, calories
                      // and millilitres all render correctly.
                      ChallengeProgressContent(
                        challenge: _challenge,
                        progress: _displayProgress,
                        fraction: _displayFraction,
                        isTracking: _isTracking,
                        // A finished or expired challenge has nothing left to
                        // track, so it loses its button rather than offering a
                        // session that cannot count.
                        onToggle: _isActionable ? _toggleSession : null,
                      ),
                      SizedBox(height: 32.h),
                      const ChallengePreviousAchievements(),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isActionable =>
      !_challenge.isCompleted && _challenge.status != ChallengeStatus.ended;

  /// Shown only when the sensors this challenge needs are actually blocked.
  Widget? get _permissionBanner {
    final walking = _walking;
    if (walking != null) {
      return switch (walking.state.permissionStatus) {
        HealthPermStatus.needsInstall => PermissionBanner(
            message: 'activity_tracking.install_health_connect'.tr(),
            onTap: walking.installHealthConnect,
          ),
        HealthPermStatus.denied => PermissionBanner(
            message: 'activity_tracking.grant_health_access'.tr(),
            onTap: walking.startTracking,
          ),
        _ => null,
      };
    }

    final running = _running;
    if (running != null && !running.state.permissionGranted) {
      return PermissionBanner(
        message: 'activity_tracking.needs_location_motion'.tr(),
        onTap: () => running.requestPermissions(context),
      );
    }
    return null;
  }
}
