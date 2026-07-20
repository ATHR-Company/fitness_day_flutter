import 'dart:async';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // ─── GPS ──────────────────────────────────────────────────────────────────
  StreamSubscription<Position>? _gpsSub;
  Position? _lastPos;

  // ─── Pedometer ────────────────────────────────────────────────────────────
  StreamSubscription<StepCount>? _stepSub;
  int? _stepBaseline; // sensor value at session start

  // ─── Timer ────────────────────────────────────────────────────────────────
  Timer? _clockTimer;
  DateTime? _startTime;

  // ─── Backend sync ─────────────────────────────────────────────────────────
  /// Distance (km) already reported to the server in this session.
  double _lastSyncedDistanceKm = 0;
  static const double _kSyncThresholdKm = 0.1; // sync every 100 m

  RunningCubit({
    required ApiService apiService,
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
    required double goalDistanceKm,
  })  : _apiService = apiService,
        super(RunningState(goalDistanceKm: goalDistanceKm));

  // ─── Public API ───────────────────────────────────────────────────────────

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
    _lastSyncedDistanceKm = 0;
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
  Future<void> close() {
    _gpsSub?.cancel();
    _stepSub?.cancel();
    _clockTimer?.cancel();
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
        if (_lastPos != null) {
          final double delta = _haversineKm(_lastPos!, pos);
          // Ignore GPS noise (> 150 m in one tick = bad fix)
          if (delta < 0.15) {
            final double newDist = state.distanceKm + delta;
            emit(state.copyWith(distanceKm: newDist));
            _maybeSyncToBackend(newDist);
          }
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
        emit(state.copyWith(steps: sessionSteps));
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

  Future<void> _syncToBackend({bool final_ = false}) async {
    final double delta =
        (state.distanceKm - _lastSyncedDistanceKm).clamp(0.0, state.distanceKm);
    // A final sync must go out even with no new distance — `isFinal` is the
    // only thing that completes a running activity server-side.
    if (delta <= 0 && !final_) return;

    try {
      final response = await _apiService.post(
        ApiEndpoints.syncRunning,
        data: {
          'assessmentId': assessmentId,
          'dayNumber': dayNumber,
          'activityId': activityId,
          // Server contract is metres, not kilometres.
          'deltaDistance': double.parse((delta * 1000).toStringAsFixed(1)),
          // TODO(backend): cumulative session time — pending confirmation that
          // the server wants a per-sync delta here. Applied with $inc today,
          // so this over-reports duration. Do not ship before that is settled.
          'durationSeconds': state.elapsedSeconds,
          'isFinal': final_,
        },
      );

      // Backend returns calories
      final dynamic calories = response.data?['data']?['caloriesBurned'];
      if (calories != null && !isClosed) {
        final double kcal = (calories as num).toDouble();
        emit(state.copyWith(caloriesKcal: kcal));
      }

      _lastSyncedDistanceKm = state.distanceKm;
    } catch (e) {
      debugPrint('RunningCubit._syncToBackend error: $e');
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
