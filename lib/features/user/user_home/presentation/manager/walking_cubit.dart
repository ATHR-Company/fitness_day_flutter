import 'dart:async';
import 'dart:io' show Platform;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
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
  final GetStorage _storage;

  /// Identifies the plan activity this progress is credited to. The backend
  /// does not infer any of these — every sync names its target explicitly.
  final String assessmentId;
  final int dayNumber;
  final String activityId;

  Timer? _pollTimer;
  static const Duration _kPollInterval = Duration(seconds: 30);

  /// Total steps/distance already reported to the server today.
  /// Persisted per calendar day *and per activity* so an app restart (or
  /// midnight rollover) can't resend a day's steps as a fresh "delta", and so
  /// two walking activities in the same day don't share one baseline.
  int _lastSentSteps = 0;
  double _lastSentDistanceKm = 0;
  String _trackedDateKey = '';

  // ─── Live pedometer (instant UI feedback between polls) ────────────────────
  StreamSubscription<StepCount>? _pedometerSub;
  int? _lastPedometerReading;
  int _pedometerBaselineForHealth = 0;
  int _healthStepsAtLastPoll = 0;

  WalkingCubit({
    required FitnessHealthService healthService,
    required ApiService apiService,
    required GetStorage storage,
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
    required double goalSteps,
    required double goalDistanceKm,
  })  : _healthService = healthService,
        _apiService = apiService,
        _storage = storage,
        super(WalkingState(
          goalSteps: goalSteps,
          goalDistanceKm: goalDistanceKm,
        ));

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> init() async {
    // Android: ensure Health Connect is installed first.
    if (Platform.isAndroid) {
      final bool available = await _healthService.isAvailable();
      if (!available) {
        emit(state.copyWith(permissionStatus: HealthPermStatus.needsInstall));
        return;
      }
    }

    final bool granted = await _healthService.requestWalkingPermissions();
    if (!granted) {
      emit(state.copyWith(permissionStatus: HealthPermStatus.denied));
      return;
    }

    emit(state.copyWith(permissionStatus: HealthPermStatus.granted));
    await _poll();
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _poll());
    await _startPedometerIfPermitted();
  }

  void pauseTracking() {
    _pollTimer?.cancel();
    _pedometerSub?.cancel();
    _pedometerSub = null;
  }

  Future<void> resumeTracking() async {
    await _poll();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _poll());
    await _startPedometerIfPermitted();
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _pedometerSub?.cancel();
    return super.close();
  }

  // ─── Core poll (ground truth from the health store) ───────────────────────

  Future<void> _poll() async {
    if (isClosed) return;
    try {
      final int steps = await _healthService.getTodaySteps();
      final metrics = await _healthService.getTodayWalkingMetrics();

      // Estimated active minutes: ~100 steps/min average walking pace
      final int minutes = steps > 0 ? (steps / 100).round() : 0;

      if (!isClosed) {
        emit(state.copyWith(
          steps: steps,
          distanceKm: metrics.distanceKm,
          caloriesKcal: metrics.caloriesKcal,
          activeMinutes: minutes,
          isLoading: false,
        ));
      }

      // Re-baseline the live pedometer against this authoritative reading so
      // it only ever contributes the delta walked *since this poll*.
      _healthStepsAtLastPoll = steps;
      if (_lastPedometerReading != null) {
        _pedometerBaselineForHealth = _lastPedometerReading!;
      }

      await _syncToBackend(steps: steps, distanceKm: metrics.distanceKm);
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

  void _startPedometer() {
    _pedometerSub?.cancel();
    _pedometerSub = Pedometer.stepCountStream.listen(
      (StepCount event) {
        // Device rebooted mid-session: the sensor's cumulative-since-boot
        // value drops below what we last saw — rebaseline instead of
        // freezing/going negative.
        if (_lastPedometerReading != null && event.steps < _lastPedometerReading!) {
          _pedometerBaselineForHealth = event.steps;
        }
        _lastPedometerReading = event.steps;
        _emitLiveSteps();
      },
      onError: (e) => debugPrint('WalkingCubit pedometer error: $e'),
      cancelOnError: false,
    );
  }

  void _emitLiveSteps() {
    if (isClosed || _lastPedometerReading == null) return;
    final int delta = _lastPedometerReading! - _pedometerBaselineForHealth;
    if (delta <= 0) return;
    final int liveSteps = _healthStepsAtLastPoll + delta;
    if (liveSteps == state.steps) return;
    final int minutes = liveSteps > 0 ? (liveSteps / 100).round() : 0;
    emit(state.copyWith(steps: liveSteps, activeMinutes: minutes));
  }

  // ─── Backend sync ─────────────────────────────────────────────────────────

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Baselines are scoped by activity as well as by day — a plan day may hold
  /// more than one walking activity, and each accumulates independently.
  String get _baselineScope => '${activityId}_$_trackedDateKey';

  /// Loads the persisted "already sent" baseline for today, scoped by
  /// calendar day. Also handles midnight rollover: once the date key
  /// changes, the baseline naturally resets to 0 for the new day.
  void _loadBaselineForToday() {
    final String key = _todayKey;
    if (key == _trackedDateKey) return;
    _trackedDateKey = key;
    _lastSentSteps = _storage.read<int>('walking_sent_steps_$_baselineScope') ?? 0;
    _lastSentDistanceKm =
        (_storage.read('walking_sent_distance_$_baselineScope') as num?)
                ?.toDouble() ??
            0.0;
  }

  Future<void> _persistBaseline() async {
    await _storage.write('walking_sent_steps_$_baselineScope', _lastSentSteps);
    await _storage.write(
        'walking_sent_distance_$_baselineScope', _lastSentDistanceKm);
  }

  /// Sends only the **delta** since last send — server accumulates the total.
  Future<void> _syncToBackend({
    required int steps,
    required double distanceKm,
  }) async {
    _loadBaselineForToday();

    final int stepDelta = (steps - _lastSentSteps).clamp(0, steps);
    final double distDelta =
        (distanceKm - _lastSentDistanceKm).clamp(0.0, distanceKm);

    if (stepDelta == 0 && distDelta == 0) return;

    try {
      await _apiService.post(
        ApiEndpoints.syncWalking,
        data: {
          'assessmentId': assessmentId,
          'dayNumber': dayNumber,
          'activityId': activityId,
          'deltaSteps': stepDelta,
          // Server contract is metres, not kilometres.
          'deltaDistance': double.parse((distDelta * 1000).toStringAsFixed(1)),
        },
      );
      _lastSentSteps = steps;
      _lastSentDistanceKm = distanceKm;
      await _persistBaseline();
    } catch (e) {
      debugPrint('WalkingCubit._syncToBackend error: $e');
      // Non-fatal — will retry on next poll
    }
  }
}
