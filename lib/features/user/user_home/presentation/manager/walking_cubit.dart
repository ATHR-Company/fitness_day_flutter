import 'dart:async';
import 'dart:io' show Platform;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/services/health_service.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';

part 'walking_state.dart';

/// Polls the OS health store every 30 s and pushes the delta to the backend.
///
/// Walking uses the Health Platform (HealthKit on iOS, Health Connect on
/// Android) — no live GPS session needed. The backend returns calories; we
/// only send distance + steps.
class WalkingCubit extends Cubit<WalkingState> {
  final FitnessHealthService _healthService;
  final ApiService _apiService;

  Timer? _pollTimer;
  static const Duration _kPollInterval = Duration(seconds: 30);

  /// Total steps/distance already reported to the server today (reset at midnight).
  int _lastSentSteps = 0;
  double _lastSentDistanceKm = 0;

  WalkingCubit({
    required FitnessHealthService healthService,
    required ApiService apiService,
    required double goalSteps,
    required double goalDistanceKm,
  })  : _healthService = healthService,
        _apiService = apiService,
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
  }

  void pauseTracking() {
    _pollTimer?.cancel();
  }

  Future<void> resumeTracking() async {
    await _poll();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _poll());
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  // ─── Core poll ────────────────────────────────────────────────────────────

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

      await _syncToBackend(steps: steps, distanceKm: metrics.distanceKm);
    } catch (e) {
      debugPrint('WalkingCubit._poll error: $e');
    }
  }

  /// Sends only the **delta** since last send — server accumulates the total.
  Future<void> _syncToBackend({
    required int steps,
    required double distanceKm,
  }) async {
    final int stepDelta = (steps - _lastSentSteps).clamp(0, steps);
    final double distDelta =
        (distanceKm - _lastSentDistanceKm).clamp(0.0, distanceKm);

    if (stepDelta == 0 && distDelta == 0) return;

    try {
      await _apiService.post(
        ApiEndpoints.updateWalking,
        data: {
          'steps': stepDelta,
          'distance': double.parse(distDelta.toStringAsFixed(3)),
        },
      );
      _lastSentSteps = steps;
      _lastSentDistanceKm = distanceKm;
    } catch (e) {
      debugPrint('WalkingCubit._syncToBackend error: $e');
      // Non-fatal — will retry on next poll
    }
  }
}
