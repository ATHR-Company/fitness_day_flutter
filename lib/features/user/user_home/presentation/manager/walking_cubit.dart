import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
// Prefixed: this package and geolocator both export an `ActivityType`.
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart' as ar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:fitness_day/core/services/health_service.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/user_home/data/models/walking_sync_model.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/sync_walking_usecase.dart';

part 'walking_state.dart';

/// Polls the OS health store every 15 s (ground truth for distance/calories
/// and backend sync) AND listens to the live hardware pedometer so the step
/// count on screen updates instantly as the user walks, instead of waiting
/// up to 15 s for the next poll.
///
/// Walking uses the Health Platform (HealthKit on iOS, Health Connect on
/// Android) as the source of truth; the pedometer stream only fills the gap
/// between polls and is re-baselined against the health store on every poll
/// so it can never drift or double-count.
class WalkingCubit extends Cubit<WalkingState> {
  final FitnessHealthService _healthService;
  final SyncWalkingUseCase _syncWalkingUseCase;

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

  /// Read the health store and sync this often. Each poll is also what pushes
  /// progress to the server, so this is the reporting cadence too.
  static const Duration _kPollInterval = Duration(seconds: 15);

  // ─── Clock ────────────────────────────────────────────────────────────────
  //
  // A real stopwatch, mirroring RunningCubit: the elapsed value is always
  // derived from [_sessionStartedAt], never accumulated tick by tick, so time
  // spent with the app backgrounded still counts and a missed tick can't drift.
  Timer? _clockTimer;
  DateTime? _sessionStartedAt;

  /// Session steps/distance already reported to the server.
  ///
  /// These are **session-relative**, matching what [_poll] produces: both reset
  /// to zero on every [startTracking]. Nothing is persisted, and nothing needs
  /// to be — a new session re-baselines against the current health reading, so
  /// steps that were already sent can never be sent again.
  int _lastSentSteps = 0;
  double _lastSentDistanceKm = 0;
  int _lastSentElapsedSeconds = 0;

  /// An attempt that was built but never acknowledged. It is retried byte-for
  /// byte — same deltas, same [_pendingSyncId] — so that if the request
  /// actually reached the server and only the response was lost, the server
  /// recognises the replay and does not apply the increment twice.
  String? _pendingSyncId;
  int _pendingDeltaSteps = 0;
  double _pendingDeltaDistanceM = 0;
  int _pendingDurationSeconds = 0;
  int _pendingTargetSteps = 0;
  double _pendingTargetDistanceKm = 0;
  int _pendingTargetElapsedSeconds = 0;

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

  /// Steps the sensor reported that the allowance could not pay for yet.
  ///
  /// Android batches step events for power, so one event can carry twenty-odd
  /// steps at once. Discarding the surplus lost real steps on every batch;
  /// queueing it here lets the next allowance tick pay it off instead.
  int _pendingRawSteps = 0;

  /// Ceiling on that queue. Long enough to absorb any plausible sensor batch,
  /// short enough that a backlog can never be cashed in as one implausible
  /// burst.
  static const int _kMaxPendingSteps = 60;

  /// A brisk walk is about 2 steps/s. Anything sustained above this is not
  /// walking — and a shaken hand sits at 2–4 Hz, which is exactly why the old
  /// 3.5 ceiling let it through untouched.
  static const double _kMaxStepsPerSecond = 2.5;

  /// Ceiling on unspent allowance, so idle time cannot bank a burst.
  static const double _kMaxStepBurst = 10;

  int get _sessionSteps => math.max(_healthSessionSteps, _pedometerSessionSteps);

  // ─── Distance ─────────────────────────────────────────────────────────────
  //
  // The health store is the preferred source, but plenty of devices never write
  // a distance record at all — the ones where `DISTANCE_DELTA` comes back empty
  // report a walk's distance as a flat 0 no matter how far the user went, and
  // `deltaDistance` was being synced as 0.0 alongside a real step count.
  // Falling back to a stride estimate keeps distance moving whenever steps are
  // being counted, and taking the larger of the two means the health store
  // still wins the moment it does report.

  /// Distance (km) the health store has attributed to this session.
  double _healthSessionDistanceKm = 0;

  /// Health-store steps recorded while GPS said the user was standing still.
  ///
  /// The platform counter reads the same hardware sensor, so a shaken phone
  /// lands in it too — and since the session total takes the larger of the two
  /// sources, filtering only the pedometer would have let those steps back in
  /// on the next poll. They are subtracted out instead.
  int _ignoredHealthSteps = 0;

  /// Health-store total at the previous poll, so each poll can tell how many of
  /// its steps are new and decide whether *those* count.
  int? _lastPolledHealthSteps;

  /// Average walking stride. Real strides vary with height and pace, so this is
  /// an estimate — used only when the health store offers nothing better.
  static const double _kStrideMetres = 0.75;

  double get _sessionDistanceKm => math.max(
        _healthSessionDistanceKm,
        _sessionSteps * _kStrideMetres / 1000,
      );

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

  /// First such fix of the session — the gate needs to have been watching for a
  /// while before "never moved" means anything.
  DateTime? _firstUsableFixAt;

  /// Last time such a fix showed the user actually displacing.
  DateTime? _lastMovementAt;

  /// Fix the displacement test measures from. Deliberately *not* advanced while
  /// the user appears still: each fix lands a few metres from the last, so
  /// re-anchoring every time would restart the measurement forever and no walk
  /// would ever clear the accuracy circle.
  Position? _movementAnchor;

  /// Fixes worse than this say nothing useful about displacement.
  static const double _kUsableAccuracyMeters = 30;

  /// Below roughly this the user is standing still; GPS jitter alone produces
  /// small non-zero speeds.
  static const double _kMinWalkingSpeedMps = 0.4;

  /// Displacement that counts as real movement regardless of the fix's own
  /// error circle — a floor for devices that report an optimistic accuracy.
  static const double _kMinDisplacementMeters = 8;

  /// A usable fix older than this is treated as gone — the user has probably
  /// walked indoors, so the gate must stop relying on it.
  static const Duration _kFixFreshness = Duration(seconds: 20);

  /// Walking is not perfectly steady and fixes arrive irregularly, so movement
  /// keeps the gate open for a short grace period rather than instantaneously.
  static const Duration _kMovementGrace = Duration(seconds: 12);

  /// How long usable fixes must show no displacement at all before the gate
  /// treats "never moved" as evidence of standing still. Long enough that the
  /// opening steps of a walk — taken before the user clears the accuracy
  /// circle — are not vetoed, short enough that standing and waving the phone
  /// stops counting quickly.
  static const Duration _kStillnessSettle = Duration(seconds: 12);

  // ─── Activity recognition ─────────────────────────────────────────────────
  //
  // The OS's own classifier, and the only signal that separates walking from a
  // phone being shaken on the spot: the step sensor counts vibration, GPS says
  // nothing indoors, but this reads the accelerometer pattern and answers
  // STILL / WALKING / RUNNING directly.
  //
  // It is treated as an override, not another vote — when it says the user is
  // on foot, steps count even if GPS disagrees; when it says STILL, nothing
  // counts. Only when it has no opinion (no Play Services, permission refused,
  // UNKNOWN) does the GPS gate decide, exactly as before.
  StreamSubscription<ar.Activity>? _activitySub;
  ar.Activity? _lastActivity;

  /// When the classifier first said STILL in the current run of STILL
  /// readings. Cleared the moment anything else arrives.
  DateTime? _stillSince;

  /// How long STILL must hold before it blocks steps. The classifier lags a few
  /// seconds behind a walk starting, so vetoing on the first STILL reading
  /// would eat the opening steps of every walk.
  static const Duration _kStillSettle = Duration(seconds: 8);

  bool _isOnFoot(ar.Activity activity) =>
      activity.type == ar.ActivityType.WALKING ||
      activity.type == ar.ActivityType.RUNNING;

  /// Whether the OS says the user is not walking right now.
  ///
  /// Deliberately conservative: a LOW-confidence reading is not evidence, and
  /// UNKNOWN means "I don't know", not "no".
  bool? get _activityVerdict {
    final ar.Activity? activity = _lastActivity;
    if (activity == null) return null;
    if (_isOnFoot(activity)) return false;

    final bool notMoving = activity.type == ar.ActivityType.STILL ||
        activity.type == ar.ActivityType.IN_VEHICLE;
    if (!notMoving || activity.confidence == ar.ActivityConfidence.LOW) {
      return null;
    }

    final DateTime? since = _stillSince;
    if (since == null) return null;
    return DateTime.now().difference(since) > _kStillSettle
        ? true
        : null;
  }

  /// The single gate every step passes through, from either source.
  ///
  /// **GPS outranks the classifier.** Waving the phone through a walking motion
  /// produces exactly the accelerometer pattern the classifier is trained on,
  /// so it reports WALKING with high confidence and cannot be used to refute
  /// it. Physical displacement can: when there is a fresh, accurate fix saying
  /// the user has not moved, that settles it no matter what the pattern looks
  /// like. Only where GPS has nothing to say — indoors, which is also where
  /// real walking goes unseen — does the classifier get the casting vote.
  bool get _shouldRejectSteps {
    if (_hasFreshFix) return _gpsContradictsMovement;
    return _activityVerdict ?? false;
  }

  /// Whether a fix arrived recently enough to be worth trusting over the
  /// accelerometer.
  bool get _hasFreshFix {
    final DateTime? fixAt = _lastUsableFixAt;
    if (fixAt == null) return false;
    return DateTime.now().difference(fixAt) <= _kFixFreshness;
  }

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
    if (movedAt == null) {
      // Never displaced since the fixes started arriving. That used to veto
      // immediately, which silently killed every live step on any device whose
      // `speed` field reads 0 — now it only counts once the gate has watched
      // long enough for a real walk to have shown itself.
      final DateTime? since = _firstUsableFixAt;
      return since != null && now.difference(since) > _kStillnessSettle;
    }
    return now.difference(movedAt) > _kMovementGrace;
  }

  WalkingCubit({
    required FitnessHealthService healthService,
    required SyncWalkingUseCase syncWalkingUseCase,
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
    required this.activityItemId,
    required double goalSteps,
    required double goalDistanceKm,
  })  : _healthService = healthService,
        _syncWalkingUseCase = syncWalkingUseCase,
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

  /// Begins a tracking session: first poll immediately, then every 15 s.
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
    _pendingRawSteps = 0;
    _healthSessionSteps = 0;
    _healthSessionDistanceKm = 0;
    _ignoredHealthSteps = 0;
    _lastPolledHealthSteps = null;
    _lastUsableFixAt = null;
    _firstUsableFixAt = null;
    _lastMovementAt = null;
    _movementAnchor = null;
    _lastActivity = null;
    _stillSince = null;
    _sessionStartedAt = DateTime.now();
    emit(state.copyWith(
      steps: 0,
      distanceKm: 0,
      caloriesKcal: 0,
      elapsedSeconds: 0,
    ));

    // The sent markers are session-relative like the readings they are compared
    // against, so they restart at zero too. Any attempt left pending from the
    // previous session was measured against a baseline that no longer exists.
    _lastSentSteps = 0;
    _lastSentDistanceKm = 0;
    _lastSentElapsedSeconds = 0;
    _pendingSyncId = null;

    await _startPedometerIfPermitted();
    await _startGpsIfPermitted();
    await _startActivityRecognitionIfPermitted();
    _startClock();
    await _poll();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _poll());
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final DateTime? startedAt = _sessionStartedAt;
    if (startedAt == null || isClosed) return;
    emit(state.copyWith(
      elapsedSeconds: DateTime.now().difference(startedAt).inSeconds,
    ));
  }

  /// Ends the session. Reads once more before stopping so the steps taken
  /// since the last 15 s poll are still reported instead of being dropped.
  Future<void> stopTracking() async {
    if (!state.isTracking) return;

    _pollTimer?.cancel();
    _pollTimer = null;
    _clockTimer?.cancel();
    _clockTimer = null;
    _stopSensors();

    // Settle the clock on its true final value before the poll syncs, so the
    // last seconds of the walk reach the server instead of being rounded off at
    // whatever the previous tick happened to be.
    _tick();
    await _poll(isFinal: true);
    if (!isClosed) emit(state.copyWith(isTracking: false));
  }

  /// Backgrounding: stop reading, but the session stays open. The clock ticks
  /// stop with it — the elapsed value is recomputed from the session start on
  /// resume, so backgrounded time is still counted.
  void pauseTracking() {
    if (!state.isTracking) return;
    _pollTimer?.cancel();
    _clockTimer?.cancel();
    _clockTimer = null;
    _stopSensors();
  }

  Future<void> resumeTracking() async {
    // Only resume a session the user actually started, and never spin a timer
    // that could read nothing but zeros.
    if (!state.isTracking ||
        state.permissionStatus != HealthPermStatus.granted) {
      return;
    }
    _tick();
    _startClock();
    await _poll();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _poll());
    await _startPedometerIfPermitted();
    await _startGpsIfPermitted();
    await _startActivityRecognitionIfPermitted();
  }

  void _stopSensors() {
    _pedometerSub?.cancel();
    _pedometerSub = null;
    _gpsSub?.cancel();
    _gpsSub = null;
    _activitySub?.cancel();
    _activitySub = null;
    // The classifier's last word is only meaningful while it is listening;
    // keeping it would let a stale STILL block the first steps after a resume.
    _lastActivity = null;
    _stillSince = null;
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    _clockTimer?.cancel();
    _stopSensors();
    // Leaving the screen mid-walk used to drop the steps taken since the last
    // 15 s poll — close cancelled everything without a final read/sync. Mirror
    // stopTracking's final poll so that tail is synced, the way RunningCubit's
    // close already does for runs.
    if (state.isTracking) {
      _tick();
      await _poll(isFinal: true);
    }
    return super.close();
  }

  // ─── Core poll (ground truth from the health store) ───────────────────────

  /// Health store readings at the moment startTracking() was invoked.
  int? _initialHealthSteps;
  double? _initialHealthDistanceKm;
  double? _initialHealthCaloriesKcal;

  Future<void> _poll({bool isFinal = false}) async {
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

      // Steps the platform recorded since the previous poll. When GPS says the
      // user did not move during that window they are shakes, not walking, and
      // are subtracted out for good — the session total takes the larger of the
      // two sources, so leaving them in would undo the pedometer's own filter.
      final int? previousHealthSteps = _lastPolledHealthSteps;
      if (previousHealthSteps != null &&
          totalHealthSteps > previousHealthSteps &&
          _shouldRejectSteps) {
        _ignoredHealthSteps += totalHealthSteps - previousHealthSteps;
      }
      _lastPolledHealthSteps = totalHealthSteps;

      _healthSessionSteps =
          (totalHealthSteps - _initialHealthSteps! - _ignoredHealthSteps)
              .clamp(0, totalHealthSteps);

      // Which signal is deciding, and what it decided. Without this the screen
      // just shows a number and there is no way to tell a vetoed walk from a
      // credited shake.
      debugPrint(
        '[Walking] gate: reject=$_shouldRejectSteps  '
        'gps=${_hasFreshFix ? (_gpsContradictsMovement ? "still" : "moving") : "none"}  '
        'activity=${_lastActivity?.type.name ?? "-"}/${_lastActivity?.confidence.name ?? "-"}  '
        'pedometer=$_pedometerSessionSteps  health=$_healthSessionSteps  ignored=$_ignoredHealthSteps',
      );

      final int sessionSteps = _sessionSteps;
      _healthSessionDistanceKm = (metrics.distanceKm - _initialHealthDistanceKm!)
          .clamp(0.0, metrics.distanceKm);
      final double sessionDistanceKm = _sessionDistanceKm;
      final double sessionCaloriesKcal = (metrics.caloriesKcal - _initialHealthCaloriesKcal!)
          .clamp(0.0, metrics.caloriesKcal);

      if (!isClosed) {
        emit(state.copyWith(
          steps: sessionSteps,
          distanceKm: sessionDistanceKm,
          caloriesKcal: sessionCaloriesKcal,
          isLoading: false,
        ));
      }

      await _syncToBackend(
        steps: sessionSteps,
        distanceKm: sessionDistanceKm,
        elapsedSeconds: state.elapsedSeconds,
        isFinal: isFinal,
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

  /// Subscribes to the OS activity classifier.
  ///
  /// Silently does nothing when the permission is refused or the device has no
  /// Play Services — the gate then falls back to GPS, which is the behaviour
  /// that existed before this signal was added.
  Future<void> _startActivityRecognitionIfPermitted() async {
    try {
      final recognition = ar.FlutterActivityRecognition.instance;
      ar.PermissionRequestResult result = await recognition.checkPermission();
      if (result == ar.PermissionRequestResult.DENIED) {
        result = await recognition.requestPermission();
      }
      if (result != ar.PermissionRequestResult.GRANTED || isClosed) return;

      _activitySub?.cancel();
      _activitySub = recognition.activityStream.listen(
        (ar.Activity activity) {
          _lastActivity = activity;
          // Track how long STILL has held. Any other verdict — including
          // UNKNOWN — ends the run, so a momentary blip cannot start the
          // veto clock over from a walk that never stopped.
          final bool isStill = activity.type == ar.ActivityType.STILL ||
              activity.type == ar.ActivityType.IN_VEHICLE;
          if (isStill && activity.confidence != ar.ActivityConfidence.LOW) {
            _stillSince ??= DateTime.now();
          } else {
            _stillSince = null;
          }
        },
        onError: (e) => debugPrint('WalkingCubit activity error: $e'),
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('WalkingCubit activity recognition error: $e');
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
        //
        // distanceFilter is 0, not 3: with a filter the stream goes quiet while
        // the user stands still, the last fix ages past _kFixFreshness, and the
        // gate falls open again — which is precisely the case it exists to
        // catch. Standing still has to keep producing fixes to be provable.
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 0,
        ),
      ).listen(
        (Position pos) {
          if (pos.accuracy > _kUsableAccuracyMeters) return;
          final DateTime now = DateTime.now();
          _lastUsableFixAt = now;
          _firstUsableFixAt ??= now;

          final Position? anchor = _movementAnchor;
          if (anchor == null) {
            _movementAnchor = pos;
            return;
          }

          // Two independent tests, because neither works everywhere:
          //
          //  - speed is the cheap one, but Android's fused provider reports a
          //    flat 0.0 and iOS reports -1 when it has no valid value, so a
          //    speed-only test declared every walk stationary.
          //  - displacement always works, measured against the anchor's own
          //    error circle so GPS jitter cannot fake it.
          final bool movingBySpeed = pos.speed >= _kMinWalkingSpeedMps;
          final double metres = Geolocator.distanceBetween(
            anchor.latitude,
            anchor.longitude,
            pos.latitude,
            pos.longitude,
          );
          final bool movingByDisplacement = metres >
              math.max(_kMinDisplacementMeters, anchor.accuracy);

          if (movingBySpeed || movingByDisplacement) {
            _lastMovementAt = now;
            _movementAnchor = pos;
          }
          // Anchor deliberately left alone otherwise — successive small hops
          // need to add up before they can clear the circle.
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
        if (_shouldRejectSteps) {
          // Drop them outright rather than queueing: they are shakes, and a
          // queue would just pay them out the moment the user takes a step.
          _pendingRawSteps = 0;
        } else {
          // Queue first, credit what the allowance can afford. The surplus
          // stays queued instead of being thrown away, so a batched sensor
          // event no longer loses the steps it could not pay for immediately.
          _pendingRawSteps =
              math.min(_pendingRawSteps + rawDelta, _kMaxPendingSteps);
          final int credited =
              math.min(_pendingRawSteps, _stepAllowance.floor());
          _pendingRawSteps -= credited;
          _pedometerSessionSteps += credited;
          _stepAllowance -= credited;
        }

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
    // Distance follows the steps between polls too, otherwise the summary card
    // sat frozen for up to 15 s on devices where the estimate is the only source.
    emit(state.copyWith(steps: liveSteps, distanceKm: _sessionDistanceKm));
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
    required int elapsedSeconds,
    bool isFinal = false,
  }) {
    final Future<void> previous = _syncQueue ?? Future<void>.value();
    final Future<void> next = previous.then((_) => _runSync(
          steps: steps,
          distanceKm: distanceKm,
          elapsedSeconds: elapsedSeconds,
          isFinal: isFinal,
        ));
    _syncQueue = next.catchError((_) {});
    return next;
  }

  Future<void> _runSync({
    required int steps,
    required double distanceKm,
    required int elapsedSeconds,
    bool isFinal = false,
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
      final int durationDelta =
          (elapsedSeconds - _lastSentElapsedSeconds).clamp(0, elapsedSeconds);

      // Elapsed time is reported on its own merit: every 15 s poll and the stop
      // press both send, so the walk's duration is credited even when the step
      // sensor contributed nothing that interval. Only a poll with genuinely
      // nothing new — no steps, no distance, no new seconds — is skipped.
      if (stepDelta == 0 && distDelta == 0 && durationDelta == 0 && !isFinal) {
        return;
      }

      _pendingSyncId = _uuid.v4();
      _pendingDeltaSteps = stepDelta;
      // Server contract is metres, not kilometres.
      _pendingDeltaDistanceM =
          double.parse((distDelta * 1000).toStringAsFixed(1));
      _pendingDurationSeconds = durationDelta;
      _pendingTargetSteps = steps;
      _pendingTargetDistanceKm = distanceKm;
      _pendingTargetElapsedSeconds = elapsedSeconds;
    }

    final ApiResult<WalkingSyncResponseModel> result = await _syncWalkingUseCase(
      WalkingSyncRequestModel(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        activityId: activityId,
        activityItemId: activityItemId,
        deltaSteps: _pendingDeltaSteps,
        deltaDistance: _pendingDeltaDistanceM,
        // Per-sync delta, not the cumulative session time: the server applies
        // this with `$inc`, so sending the running total would compound.
        durationSeconds: _pendingDurationSeconds,
        syncId: _pendingSyncId!,
      ),
    );

    switch (result) {
      case Success():
        _lastSentSteps = _pendingTargetSteps;
        _lastSentDistanceKm = _pendingTargetDistanceKm;
        _lastSentElapsedSeconds = _pendingTargetElapsedSeconds;
        _pendingSyncId = null;
      case FailureResult(:final failure):
        debugPrint('WalkingCubit._syncToBackend error: ${failure.message}');
      // Non-fatal — the pending attempt is retried unchanged on the next poll.
    }
  }
}
