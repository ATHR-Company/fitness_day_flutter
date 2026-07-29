import 'dart:async';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';

part 'running_state.dart';

/// Live running session tracker — GPS distance + pedometer steps + elapsed time.
///
/// Distance:  GPS Haversine (accurate for outdoor runs).
/// Steps:     Hardware pedometer delta since session start.
/// Calories:  Sent by the backend after we POST distance.
/// Time:      Real stopwatch from start() to stop().
class RunningCubit extends Cubit<RunningState> {
  final ApiService _apiService;

  /// Identifies the plan activity this progress is credited to. Captured when
  /// the screen opens and deliberately frozen for the whole session — a run
  /// that crosses midnight is one session and stays on its starting day.
  final String assessmentId;
  final int dayNumber;
  final String activityId;

  /// Unique `_id` of the item inside the plan day. [activityId] is only the
  /// catalog reference and is shared by every running item in the day, so the
  /// server matches on this instead — without it a day holding two running
  /// activities would credit both on every sync.
  final String activityItemId;

  // ─── GPS ──────────────────────────────────────────────────────────────────
  StreamSubscription<Position>? _gpsSub;
  Position? _lastPos;

  /// Distance accumulated from GPS alone, kept apart from the published total
  /// so the pedometer fallback can be compared against it.
  double _gpsDistanceKm = 0;

  // ─── Distance fallback ────────────────────────────────────────────────────
  //
  // GPS is the accurate source, but it produces nothing at all when location is
  // switched off, indoors, or on a treadmill — and the session then synced
  // `deltaDistance: 0.0` however far the user actually ran. Estimating from the
  // pedometer keeps a run credited; taking the larger of the two means GPS wins
  // outright whenever it is working, which is almost always outdoors.

  /// Average running stride. An estimate — only consulted when GPS gives less.
  static const double _kStrideMetres = 1.0;

  double _distanceFor(int steps) =>
      math.max(_gpsDistanceKm, steps * _kStrideMetres / 1000);

  // ─── Pedometer ────────────────────────────────────────────────────────────
  StreamSubscription<StepCount>? _stepSub;
  int? _stepBaseline; // sensor value at session start

  // ─── Timer ────────────────────────────────────────────────────────────────
  Timer? _clockTimer;
  DateTime? _startTime;

  // ─── Backend sync ─────────────────────────────────────────────────────────
  /// Distance (km) and elapsed time already reported to the server in this
  /// session. Both endpoints apply the payload with `$inc`, so every request
  /// carries the delta since these marks — never a cumulative total.
  double _lastSyncedDistanceKm = 0;
  int _lastSyncedElapsedSeconds = 0;
  /// Sync every 5 m — the same distance as the GPS stream's own
  /// `distanceFilter`, so effectively every fix that counts as movement sends.
  static const double _kSyncThresholdKm = 0.005;

  /// Fixes worse than this are treated as noise rather than movement.
  static const double _kMaxAcceptableAccuracyMeters = 25;

  /// Below a slow walk (~1.8 km/h) the user is standing still and the reading
  /// is drift, not progress.
  static const double _kMinMovingSpeedMps = 0.5;

  /// An attempt that was built but never acknowledged. Retried byte-for-byte —
  /// same deltas, same [_pendingSyncId] — so a request that reached the server
  /// but whose response was lost is recognised as a replay instead of being
  /// applied twice.
  String? _pendingSyncId;
  double _pendingDeltaM = 0;
  int _pendingDurationSeconds = 0;
  bool _pendingIsFinal = false;
  double _pendingTargetDistanceKm = 0;
  int _pendingTargetElapsedSeconds = 0;

  /// Tail of the in-flight sync chain — see [_syncToBackend].
  Future<void>? _syncQueue;

  static const Uuid _uuid = Uuid();

  RunningCubit({
    required ApiService apiService,
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
    required this.activityItemId,
    required double goalDistanceKm,
  })  : _apiService = apiService,
        super(RunningState(goalDistanceKm: goalDistanceKm));

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Reads the existing grants **without prompting**.
  ///
  /// `permissionGranted` starts false on every freshly built cubit, so without
  /// this the permission banner reappears each time the screen opens even
  /// though the user granted everything long ago.
  Future<void> refreshPermissionStatus() async {
    try {
      final Permission motion = defaultTargetPlatform == TargetPlatform.iOS
          ? Permission.sensors
          : Permission.activityRecognition;

      final bool motionGranted = await motion.isGranted;
      final LocationPermission locPerm = await Geolocator.checkPermission();
      final bool locationGranted = locPerm == LocationPermission.always ||
          locPerm == LocationPermission.whileInUse;

      if (!isClosed && motionGranted && locationGranted) {
        emit(state.copyWith(permissionGranted: true));
      }
    } catch (e) {
      debugPrint('RunningCubit.refreshPermissionStatus error: $e');
    }
  }

  Future<bool> requestPermissions() async {
    // Motion / activity recognition
    // iOS: pedometer uses CoreMotion → NSMotionUsageDescription (Info.plist)
    //      permission_handler's Permission.sensors covers CoreMotion on iOS.
    // Android: ACTIVITY_RECOGNITION is the explicit runtime permission.
    final Permission motion =
        defaultTargetPlatform == TargetPlatform.iOS
            ? Permission.sensors
            : Permission.activityRecognition;
    if (!await _grant(motion)) return false;

    // Location (fine) — needed for GPS distance
    LocationPermission locPerm = await Geolocator.checkPermission();
    if (locPerm == LocationPermission.denied) {
      locPerm = await Geolocator.requestPermission();
    }
    if (locPerm == LocationPermission.denied ||
        locPerm == LocationPermission.deniedForever) {
      return false;
    }

    emit(state.copyWith(permissionGranted: true));
    return true;
  }

  Future<void> startSession() async {
    if (state.isRunning) return;
    if (!state.permissionGranted) {
      final ok = await requestPermissions();
      if (!ok) return;
    }

    _lastPos = null;
    _stepBaseline = null;
    _gpsDistanceKm = 0;
    _lastSyncedDistanceKm = 0;
    _lastSyncedElapsedSeconds = 0;
    _pendingSyncId = null;
    _startTime = DateTime.now();

    emit(state.copyWith(
      isRunning: true,
      distanceKm: 0,
      steps: 0,
      caloriesKcal: 0,
      elapsedSeconds: 0,
      sessionFinished: false,
    ));

    _startGps();
    _startPedometer();
    _startClock();
  }

  Future<void> stopSession() async {
    if (!state.isRunning) return;

    _gpsSub?.cancel();
    _stepSub?.cancel();
    _clockTimer?.cancel();
    _gpsSub = null;
    _stepSub = null;
    _clockTimer = null;

    // Final sync
    await _syncToBackend(final_: true);

    emit(state.copyWith(isRunning: false, sessionFinished: true));
  }

  @override
  Future<void> close() async {
    _gpsSub?.cancel();
    _stepSub?.cancel();
    _clockTimer?.cancel();

    // Navigating away mid-run used to drop the session outright: the unsynced
    // tail (under the 100 m threshold) was lost and `isFinal` never reached the
    // server, so the activity stayed open forever. Close it out first — the
    // subscriptions are already cancelled, so nothing can mutate state under us.
    if (state.isRunning) {
      await _syncToBackend(final_: true);
    }
    return super.close();
  }

  // ─── GPS tracking ─────────────────────────────────────────────────────────

  void _startGps() {
    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // update every 5 metres
      ),
    ).listen(
      (Position pos) {
        // Drop low-confidence fixes outright. Without this, a stationary phone
        // still drifts past the 5 m filter and silently accumulates distance
        // over a long session. The anchor is deliberately left alone — making a
        // fix we don't trust the reference point for the next measurement would
        // fold its own error straight into the distance.
        if (pos.accuracy > _kMaxAcceptableAccuracyMeters) return;

        if (_lastPos == null) {
          _lastPos = pos;
          return;
        }

        final double delta = _haversineKm(_lastPos!, pos);

        // Standing still still wanders past the 5 m filter, so require evidence
        // of actual movement: either a reported speed in the walking-or-faster
        // range, or a displacement larger than the fix's own error circle. The
        // second test covers devices that never report a usable speed.
        final bool movingBySpeed = pos.speed >= _kMinMovingSpeedMps;
        final bool movingByDisplacement = delta * 1000 > pos.accuracy;
        if (!movingBySpeed && !movingByDisplacement) {
          // Hold the anchor. Advancing it here was why devices that report no
          // speed accumulated nothing at all: each fix arrives ~5 m after the
          // last, so a single hop can never exceed a 10–25 m accuracy circle,
          // and re-anchoring every time meant the displacement test restarted
          // from scratch forever. Keeping the anchor lets successive hops add
          // up until they clear the circle, and then they are credited.
          return;
        }

        // Ignore GPS noise (> 150 m in one tick = bad fix)
        if (delta < 0.15) {
          _gpsDistanceKm += delta;
          final double newDist = _distanceFor(state.steps);
          emit(state.copyWith(distanceKm: newDist));
          _maybeSyncToBackend(newDist);
        }
        _lastPos = pos;
      },
      onError: (e) => debugPrint('RunningCubit GPS error: $e'),
    );
  }

  // ─── Pedometer ────────────────────────────────────────────────────────────

  void _startPedometer() {
    _stepSub = Pedometer.stepCountStream.listen(
      (StepCount event) {
        final int total = event.steps;
        _stepBaseline ??= total; // baseline = value at session start
        // Device rebooted mid-session: the sensor's cumulative-since-boot
        // value drops below our baseline — rebaseline instead of freezing.
        if (total < _stepBaseline!) {
          _stepBaseline = total;
        }
        final int sessionSteps = (total - _stepBaseline!).clamp(0, total);
        // Steps feed the distance fallback, so a run with no usable GPS still
        // reports progress instead of syncing 0.0 forever.
        final double newDist = _distanceFor(sessionSteps);
        emit(state.copyWith(steps: sessionSteps, distanceKm: newDist));
        _maybeSyncToBackend(newDist);
      },
      onError: (e) => debugPrint('RunningCubit pedometer error: $e'),
      cancelOnError: false,
    );
  }

  // ─── Clock ────────────────────────────────────────────────────────────────

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime == null || isClosed) return;
      final int elapsed =
          DateTime.now().difference(_startTime!).inSeconds;
      emit(state.copyWith(elapsedSeconds: elapsed));
    });
  }

  // ─── Backend sync ─────────────────────────────────────────────────────────

  void _maybeSyncToBackend(double distanceKm) {
    if (distanceKm - _lastSyncedDistanceKm >= _kSyncThresholdKm) {
      _syncToBackend();
    }
  }

  /// Serialises syncs. GPS ticks fire these without awaiting, so two could
  /// otherwise both see no pending attempt, both build one, and the second
  /// would overwrite the first's payload — acknowledging the first would then
  /// advance the marks past distance that was never actually sent.
  Future<void> _syncToBackend({bool final_ = false}) {
    final Future<void> previous = _syncQueue ?? Future<void>.value();
    final Future<void> next = previous.then((_) => _runSync(final_: final_));
    _syncQueue = next.catchError((_) {});
    return next;
  }

  Future<void> _runSync({bool final_ = false}) async {
    // The server matches on activityItemId; without it the request would be
    // rejected, so keep the progress in the session marks and report it once
    // the details response carries the id.
    if (activityItemId.isEmpty) return;

    // Flush an outstanding attempt first, unchanged. Its payload cannot be
    // merged into this one: reusing the syncId with different contents would
    // be replay-protected server-side and silently dropped.
    if (_pendingSyncId != null && !await _postPending()) return;

    final double delta =
        (state.distanceKm - _lastSyncedDistanceKm).clamp(0.0, state.distanceKm);
    final int durationDelta = (state.elapsedSeconds - _lastSyncedElapsedSeconds)
        .clamp(0, state.elapsedSeconds);

    // A final sync must go out even with nothing new — `isFinal` is the only
    // thing that completes a running activity server-side.
    if (delta <= 0 && durationDelta <= 0 && !final_) return;

    _pendingSyncId = _uuid.v4();
    // Server contract is metres, not kilometres.
    _pendingDeltaM = double.parse((delta * 1000).toStringAsFixed(1));
    _pendingDurationSeconds = durationDelta;
    _pendingIsFinal = final_;
    _pendingTargetDistanceKm = state.distanceKm;
    _pendingTargetElapsedSeconds = state.elapsedSeconds;

    await _postPending();
  }

  /// Sends the outstanding attempt. Returns true once it is acknowledged.
  Future<bool> _postPending() async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.syncRunning,
        data: {
          'assessmentId': assessmentId,
          'dayNumber': dayNumber,
          'activityId': activityId,
          'activityItemId': activityItemId,
          'deltaDistance': _pendingDeltaM,
          // Per-sync delta, not the cumulative session time: the server applies
          // this with `$inc`, so sending the running total would compound.
          'durationSeconds': _pendingDurationSeconds,
          'isFinal': _pendingIsFinal,
          'syncId': _pendingSyncId,
        },
      );

      // Backend returns calories
      final dynamic calories = response.data?['data']?['caloriesBurned'];
      if (calories != null && !isClosed) {
        final double kcal = (calories as num).toDouble();
        emit(state.copyWith(caloriesKcal: kcal));
      }

      _lastSyncedDistanceKm = _pendingTargetDistanceKm;
      _lastSyncedElapsedSeconds = _pendingTargetElapsedSeconds;
      _pendingSyncId = null;
      return true;
    } catch (e) {
      debugPrint('RunningCubit._syncToBackend error: $e');
      return false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static double _haversineKm(Position a, Position b) {
    const double r = 6371.0;
    final double dLat = _rad(b.latitude - a.latitude);
    final double dLon = _rad(b.longitude - a.longitude);
    final double h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  static double _rad(double deg) => deg * math.pi / 180;

  Future<bool> _grant(Permission p) async {
    if (await p.isGranted) return true;
    return await p.request() == PermissionStatus.granted;
  }
}
