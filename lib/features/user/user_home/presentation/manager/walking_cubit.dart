import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:fitness_day/core/services/health_service.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';

part 'walking_state.dart';

/// Polls the OS health store every 30 s (ground truth for distance/calories
/// and backend sync) AND listens to the live hardware pedometer so the step
/// count on screen updates instantly as the user walks, instead of waiting
/// up to 30 s for the next poll.
///
/// Walking uses the Health Platform (HealthKit on iOS, Health Connect on
/// Android) as the source of truth; the pedometer stream only fills the gap
/// between polls and is re-baselined against the health store on every poll
/// so it can never drift or double-count.
class WalkingCubit extends Cubit<WalkingState> {
  final FitnessHealthService _healthService;
  final ApiService _apiService;

  /// Identifies the plan activity this progress is credited to. The backend
  /// does not infer any of these — every sync names its target explicitly.
  final String assessmentId;
  final int dayNumber;
  final String activityId;

  /// Unique `_id` of the item inside the plan day. [activityId] is only the
  /// catalog reference and is shared by every walking item in the day, so the
  /// server matches on this instead — without it a day holding two walking
  /// activities would credit both on every sync.
  final String activityItemId;

  Timer? _pollTimer;
  static const Duration _kPollInterval = Duration(seconds: 30);

  /// Session steps/distance already reported to the server.
  ///
  /// These are **session-relative**, matching what [_poll] produces: both reset
  /// to zero on every [startTracking]. Nothing is persisted, and nothing needs
  /// to be — a new session re-baselines against the current health reading, so
  /// steps that were already sent can never be sent again.
  int _lastSentSteps = 0;
  double _lastSentDistanceKm = 0;

  /// An attempt that was built but never acknowledged. It is retried byte-for
  /// byte — same deltas, same [_pendingSyncId] — so that if the request
  /// actually reached the server and only the response was lost, the server
  /// recognises the replay and does not apply the increment twice.
  String? _pendingSyncId;
  int _pendingDeltaSteps = 0;
  double _pendingDeltaDistanceM = 0;
  int _pendingTargetSteps = 0;
  double _pendingTargetDistanceKm = 0;

  /// Tail of the in-flight sync chain — see [_syncToBackend].
  Future<void>? _syncQueue;

  static const Uuid _uuid = Uuid();

  // ─── Step sources ─────────────────────────────────────────────────────────
  //
  // Two of them, because neither is reliable alone. The health store applies
  // the platform's own filtering but writes in batches — on some devices
  // (notably MIUI) it does not flush for minutes, so a whole walk can pass with
  // the reading frozen. The hardware sensor is immediate but unfiltered.
  //
  // Both are monotonic within a session, so the session total is simply
  // whichever is further along; that keeps the count live *and* lets the health
  // store's higher figure win once it finally catches up.
  StreamSubscription<StepCount>? _pedometerSub;
  int? _lastPedometerReading;
  int? _pedometerAtSessionStart;
  DateTime? _lastPedometerEventAt;
  int _healthSessionSteps = 0;

  /// Sensor steps this session, after the cadence filter in [_startPedometer].
  int _pedometerSessionSteps = 0;

  /// Unspent step budget, in steps — see the token bucket in [_startPedometer].
  double _stepAllowance = 0;

  /// A brisk walk runs about 2 steps/s and a hard run about 3.5. Sustained
  /// rates above this are not locomotion, so they are not credited.
  static const double _kMaxStepsPerSecond = 3.5;

  /// Ceiling on unspent allowance, so idle time cannot bank a burst.
  static const double _kMaxStepBurst = 10;

  int get _sessionSteps => math.max(_healthSessionSteps, _pedometerSessionSteps);

  // ─── GPS corroboration ────────────────────────────────────────────────────
  //
  // The step sensor cannot tell walking from the phone being shaken. When a
  // trustworthy GPS fix is available, steps are only credited while the user is
  // actually displacing. Indoors — where a fix is absent or too coarse, and
  // where much real walking happens — the gate opens and the cadence filter
  // alone decides, rather than silently refusing to count.
  StreamSubscription<Position>? _gpsSub;

  /// Last time a fix arrived that was accurate enough to be worth believing.
  DateTime? _lastUsableFixAt;

  /// Last time such a fix showed the user actually displacing.
  DateTime? _lastMovementAt;

  /// Fixes worse than this say nothing useful about displacement.
  static const double _kUsableAccuracyMeters = 30;

  /// Below roughly this the user is standing still; GPS jitter alone produces
  /// small non-zero speeds.
  static const double _kMinWalkingSpeedMps = 0.4;

  /// A usable fix older than this is treated as gone — the user has probably
  /// walked indoors, so the gate must stop relying on it.
  static const Duration _kFixFreshness = Duration(seconds: 20);

  /// Walking is not perfectly steady and fixes arrive irregularly, so movement
  /// keeps the gate open for a short grace period rather than instantaneously.
  static const Duration _kMovementGrace = Duration(seconds: 12);

  /// Whether GPS is actively contradicting the step sensor.
  ///
  /// Only true when there is a *fresh, accurate* fix that shows no movement —
  /// i.e. the phone is being shaken while standing still. With no fix, a stale
  /// fix, or a coarse one, this is false: the gate fails open and the cadence
  /// filter decides on its own.
  bool get _gpsContradictsMovement {
    final DateTime? fixAt = _lastUsableFixAt;
    if (fixAt == null) return false;

    final DateTime now = DateTime.now();
    if (now.difference(fixAt) > _kFixFreshness) return false;

    final DateTime? movedAt = _lastMovementAt;
    if (movedAt == null) return true;
    return now.difference(movedAt) > _kMovementGrace;
  }

  WalkingCubit({
    required FitnessHealthService healthService,
    required ApiService apiService,
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
    required this.activityItemId,
    required double goalSteps,
    required double goalDistanceKm,
  })  : _healthService = healthService,
        _apiService = apiService,
        super(WalkingState(
          goalSteps: goalSteps,
          goalDistanceKm: goalDistanceKm,
        ));

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// Resolves health access, asking the user only when it isn't already held.
  ///
  /// Once granted the result is remembered in state, so pressing start again
  /// later in the same session never re-prompts; and even on a fresh cubit the
  /// underlying `hasPermissions` check short-circuits before any dialog.
  Future<bool> _ensurePermissions() async {
    if (state.permissionStatus == HealthPermStatus.granted) return true;

    // Android: Health Connect has to exist before permissions mean anything.
    if (Platform.isAndroid) {
      final bool available = await _healthService.isAvailable();
      if (!available) {
        emit(state.copyWith(permissionStatus: HealthPermStatus.needsInstall));
        return false;
      }
    }

    final bool granted = await _healthService.requestWalkingPermissions();
    emit(state.copyWith(
      permissionStatus:
          granted ? HealthPermStatus.granted : HealthPermStatus.denied,
    ));
    return granted;
  }

  /// Opens the Play Store listing so the user can install Health Connect.
  ///
  /// The needsInstall banner button used to just re-run [startTracking], which
  /// re-checked availability and did nothing — permissions are meaningless for
  /// a component that isn't installed. This actually launches the install flow.
  Future<void> installHealthConnect() async {
    await _healthService.promptInstall();
  }

  /// Begins a tracking session: first poll immediately, then every 30 s.
  Future<void> startTracking() async {
    if (state.isTracking) return;
    if (!await _ensurePermissions()) return;
    if (isClosed) return;

    emit(state.copyWith(isTracking: true));
    _initialHealthSteps = null;
    _initialHealthDistanceKm = null;
    _initialHealthCaloriesKcal = null;
    _lastPedometerReading = null;
    _pedometerAtSessionStart = null;
    _lastPedometerEventAt = null;
    _pedometerSessionSteps = 0;
    _stepAllowance = 0;
    _healthSessionSteps = 0;
    _lastUsableFixAt = null;
    _lastMovementAt = null;
    emit(state.copyWith(steps: 0, distanceKm: 0, caloriesKcal: 0));

    // The sent markers are session-relative like the readings they are compared
    // against, so they restart at zero too. Any attempt left pending from the
    // previous session was measured against a baseline that no longer exists.
    _lastSentSteps = 0;
    _lastSentDistanceKm = 0;
    _pendingSyncId = null;

    await _startPedometerIfPermitted();
    await _startGpsIfPermitted();
    await _poll();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _poll());
  }

  /// Ends the session. Reads once more before stopping so the steps taken
  /// since the last 30 s poll are still reported instead of being dropped.
  Future<void> stopTracking() async {
    if (!state.isTracking) return;

    _pollTimer?.cancel();
    _pollTimer = null;
    _stopSensors();

    await _poll();
    if (!isClosed) emit(state.copyWith(isTracking: false));
  }

  /// Backgrounding: stop reading, but the session stays open.
  void pauseTracking() {
    if (!state.isTracking) return;
    _pollTimer?.cancel();
    _stopSensors();
  }

  Future<void> resumeTracking() async {
    // Only resume a session the user actually started, and never spin a timer
    // that could read nothing but zeros.
    if (!state.isTracking ||
        state.permissionStatus != HealthPermStatus.granted) {
      return;
    }
    await _poll();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _poll());
    await _startPedometerIfPermitted();
    await _startGpsIfPermitted();
  }

  void _stopSensors() {
    _pedometerSub?.cancel();
    _pedometerSub = null;
    _gpsSub?.cancel();
    _gpsSub = null;
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    _stopSensors();
    // Leaving the screen mid-walk used to drop the steps taken since the last
    // 30 s poll — close cancelled everything without a final read/sync. Mirror
    // stopTracking's final poll so that tail is synced, the way RunningCubit's
    // close already does for runs.
    if (state.isTracking) {
      await _poll();
    }
    return super.close();
  }

  // ─── Core poll (ground truth from the health store) ───────────────────────

  /// Health store readings at the moment startTracking() was invoked.
  int? _initialHealthSteps;
  double? _initialHealthDistanceKm;
  double? _initialHealthCaloriesKcal;

  Future<void> _poll() async {
    if (isClosed) return;
    try {
      final int totalHealthSteps = await _healthService.getTodaySteps();
      final metrics = await _healthService.getTodayWalkingMetrics();

      // Establish baseline on the first poll of a session
      if (_initialHealthSteps == null) {
        _initialHealthSteps = totalHealthSteps;
        _initialHealthDistanceKm = metrics.distanceKm;
        _initialHealthCaloriesKcal = metrics.caloriesKcal;
      }

      _healthSessionSteps =
          (totalHealthSteps - _initialHealthSteps!).clamp(0, totalHealthSteps);

      final int sessionSteps = _sessionSteps;
      final double sessionDistanceKm = (metrics.distanceKm - _initialHealthDistanceKm!)
          .clamp(0.0, metrics.distanceKm);
      final double sessionCaloriesKcal = (metrics.caloriesKcal - _initialHealthCaloriesKcal!)
          .clamp(0.0, metrics.caloriesKcal);

      // Estimated active minutes for session steps
      final int minutes = sessionSteps > 0 ? (sessionSteps / 100).round() : 0;

      if (!isClosed) {
        emit(state.copyWith(
          steps: sessionSteps,
          distanceKm: sessionDistanceKm,
          caloriesKcal: sessionCaloriesKcal,
          activeMinutes: minutes,
          isLoading: false,
        ));
      }

      await _syncToBackend(
        steps: sessionSteps,
        distanceKm: sessionDistanceKm,
      );
    } catch (e) {
      debugPrint('WalkingCubit._poll error: $e');
    }
  }

  // ─── Live pedometer (instant step feedback between polls) ─────────────────

  Future<void> _startPedometerIfPermitted() async {
    try {
      final Permission motion =
          Platform.isIOS ? Permission.sensors : Permission.activityRecognition;
      final bool granted =
          await motion.isGranted || await motion.request() == PermissionStatus.granted;
      if (granted && !isClosed) _startPedometer();
    } catch (e) {
      debugPrint('WalkingCubit motion permission error: $e');
    }
  }

  /// Starts location updates purely as a corroboration signal — no distance is
  /// derived from them. Silently does nothing without permission, in which case
  /// the cadence filter remains the only check.
  Future<void> _startGpsIfPermitted() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      if (isClosed) return;

      _gpsSub?.cancel();
      _gpsSub = Geolocator.getPositionStream(
        // Medium accuracy is enough to answer "is this person moving at all?"
        // and costs far less battery than the navigation-grade modes.
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 3,
        ),
      ).listen(
        (Position pos) {
          if (pos.accuracy > _kUsableAccuracyMeters) return;
          final DateTime now = DateTime.now();
          _lastUsableFixAt = now;
          if (pos.speed >= _kMinWalkingSpeedMps) _lastMovementAt = now;
        },
        onError: (e) => debugPrint('WalkingCubit GPS error: $e'),
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('WalkingCubit GPS permission error: $e');
    }
  }

  void _startPedometer() {
    _pedometerSub?.cancel();
    _pedometerSub = Pedometer.stepCountStream.listen(
      (StepCount event) {
        final DateTime now = DateTime.now();

        // The sensor counts cumulatively since boot. Anchor on the first
        // reading of the session; a value below the anchor means the device
        // rebooted, so re-anchor rather than going negative. Nothing is
        // credited on the anchor event itself.
        if (_pedometerAtSessionStart == null ||
            _lastPedometerReading == null ||
            event.steps < _pedometerAtSessionStart!) {
          _pedometerAtSessionStart = event.steps;
          _lastPedometerReading = event.steps;
          _lastPedometerEventAt = now;
          return;
        }

        final int rawDelta = event.steps - _lastPedometerReading!;
        final double elapsedSeconds =
            now.difference(_lastPedometerEventAt ?? now).inMilliseconds / 1000.0;

        // Token bucket: the sensor is a vibration counter, so shaking the phone
        // registers as steps. Real locomotion cannot exceed a few steps per
        // second, so only that much may be credited per unit of time. The
        // allowance accrues while walking and is capped, so standing still for
        // a while then shaking cannot cash in a large backlog.
        _stepAllowance = math.min(
          _stepAllowance + elapsedSeconds * _kMaxStepsPerSecond,
          _kMaxStepBurst,
        );

        // GPS veto: a fresh, accurate fix showing no displacement means these
        // "steps" are the phone being moved, not the user walking. Indoors the
        // gate fails open and the cadence filter stands alone.
        final int credited = _gpsContradictsMovement
            ? 0
            : rawDelta.clamp(0, _stepAllowance.floor());
        _pedometerSessionSteps += credited;
        _stepAllowance -= credited;

        _lastPedometerReading = event.steps;
        _lastPedometerEventAt = now;
        _emitLiveSteps();
      },
      onError: (e) => debugPrint('WalkingCubit pedometer error: $e'),
      cancelOnError: false,
    );
  }

  void _emitLiveSteps() {
    if (isClosed) return;
    final int liveSteps = _sessionSteps;
    // Forward-only: never publish a lower count than what is already on screen.
    if (liveSteps <= state.steps) return;
    final int minutes = liveSteps > 0 ? (liveSteps / 100).round() : 0;
    emit(state.copyWith(steps: liveSteps, activeMinutes: minutes));
  }

  // ─── Backend sync ─────────────────────────────────────────────────────────

  /// Sends only the **delta** since last send — server accumulates the total.
  ///
  /// Serialised: a slow request must not overlap the next poll, or both would
  /// see no pending attempt, both build one, and the second would overwrite the
  /// first's payload — acknowledging the first would then advance the baseline
  /// past steps that were never actually sent.
  Future<void> _syncToBackend({
    required int steps,
    required double distanceKm,
  }) {
    final Future<void> previous = _syncQueue ?? Future<void>.value();
    final Future<void> next = previous
        .then((_) => _runSync(steps: steps, distanceKm: distanceKm));
    _syncQueue = next.catchError((_) {});
    return next;
  }

  Future<void> _runSync({
    required int steps,
    required double distanceKm,
  }) async {
    // The server matches on activityItemId; without it the request would be
    // rejected, so hold the progress in the session markers and retry once the
    // details response carries the id.
    if (activityItemId.isEmpty) return;

    // Reuse an unacknowledged attempt verbatim; only build a fresh one when
    // nothing is outstanding.
    if (_pendingSyncId == null) {
      final int stepDelta = (steps - _lastSentSteps).clamp(0, steps);
      final double distDelta =
          (distanceKm - _lastSentDistanceKm).clamp(0.0, distanceKm);

      if (stepDelta == 0 && distDelta == 0) return;

      _pendingSyncId = _uuid.v4();
      _pendingDeltaSteps = stepDelta;
      // Server contract is metres, not kilometres.
      _pendingDeltaDistanceM =
          double.parse((distDelta * 1000).toStringAsFixed(1));
      _pendingTargetSteps = steps;
      _pendingTargetDistanceKm = distanceKm;
    }

    try {
      await _apiService.post(
        ApiEndpoints.syncWalking,
        data: {
          'assessmentId': assessmentId,
          'dayNumber': dayNumber,
          'activityId': activityId,
          'activityItemId': activityItemId,
          'deltaSteps': _pendingDeltaSteps,
          'deltaDistance': _pendingDeltaDistanceM,
          'syncId': _pendingSyncId,
        },
      );
      _lastSentSteps = _pendingTargetSteps;
      _lastSentDistanceKm = _pendingTargetDistanceKm;
      _pendingSyncId = null;
    } catch (e) {
      debugPrint('WalkingCubit._syncToBackend error: $e');
      // Non-fatal — the pending attempt is retried unchanged on the next poll.
    }
  }
}
