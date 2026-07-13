import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// Wraps HealthKit (iOS) and Health Connect (Android).
/// Reads steps + distance + calories for today's walking activity.
class FitnessHealthService {
  final Health _health = Health();
  bool _configured = false;
  bool _historyAuthRequested = false;

  Future<void> configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<void> _ensureConfigured() async {
    if (!_configured) await configure();
  }

  /// Android: is Health Connect installed?
  Future<bool> isAvailable() async {
    try {
      await _ensureConfigured();
      if (Platform.isAndroid) return await _health.isHealthConnectAvailable();
      return true; // iOS HealthKit always available
    } catch (e) {
      debugPrint('FitnessHealthService.isAvailable error: $e');
      return false;
    }
  }

  /// Prompt Android user to install Health Connect from Play Store.
  Future<void> promptInstall() async {
    try {
      await _health.installHealthConnect();
    } catch (_) {}
  }

  // ─── Types ────────────────────────────────────────────────────────────────

  HealthDataType get _distanceType => Platform.isIOS
      ? HealthDataType.DISTANCE_WALKING_RUNNING
      : HealthDataType.DISTANCE_DELTA;

  HealthDataType get _caloriesType => Platform.isIOS
      ? HealthDataType.ACTIVE_ENERGY_BURNED
      : HealthDataType.TOTAL_CALORIES_BURNED;

  List<HealthDataType> get _walkingTypes => [
        HealthDataType.STEPS,
        _distanceType,
        _caloriesType,
      ];

  // ─── Permissions ──────────────────────────────────────────────────────────

  Future<bool> requestWalkingPermissions() async {
    try {
      await _ensureConfigured();
      final perms = List<HealthDataAccess>.filled(
        _walkingTypes.length,
        HealthDataAccess.READ,
      );
      final bool? has =
          await _health.hasPermissions(_walkingTypes, permissions: perms);
      if (has == true) return true;
      final bool granted =
          await _health.requestAuthorization(_walkingTypes, permissions: perms);
      if (Platform.isAndroid && !_historyAuthRequested) {
        try {
          await _health.requestHealthDataHistoryAuthorization();
          _historyAuthRequested = true;
        } catch (_) {}
      }
      return granted;
    } catch (e) {
      debugPrint('requestWalkingPermissions error: $e');
      return false;
    }
  }

  // ─── Data reads ───────────────────────────────────────────────────────────

  /// Today's total steps from the health store.
  Future<int> getTodaySteps() async {
    try {
      await _ensureConfigured();
      if (Platform.isAndroid && !_historyAuthRequested) {
        try {
          await _health.requestHealthDataHistoryAuthorization();
          _historyAuthRequested = true;
        } catch (_) {}
      }
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      int? steps = await _health.getTotalStepsInInterval(start, now);

      // iOS fallback: sum raw data points
      if ((steps == null || steps == 0) && Platform.isIOS) {
        final points = await _health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: start,
          endTime: now,
        );
        if (points.isNotEmpty) {
          steps = points
              .map((e) => (e.value as NumericHealthValue).numericValue.toInt())
              .fold<int>(0, (a, b) => a + b);
        }
      }
      return steps ?? 0;
    } catch (e) {
      debugPrint('getTodaySteps error: $e');
      return 0;
    }
  }

  /// Today's distance (km) + calories (kcal) from the health store.
  Future<({double distanceKm, double caloriesKcal})> getTodayWalkingMetrics() async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      List<HealthDataPoint> points = await _health.getHealthDataFromTypes(
        types: [_distanceType, _caloriesType],
        startTime: start,
        endTime: now,
      );
      points = _health.removeDuplicates(points);

      double distanceMeters = 0;
      double calories = 0;
      for (final p in points) {
        final double v = p.value is NumericHealthValue
            ? (p.value as NumericHealthValue).numericValue.toDouble()
            : 0.0;
        if (p.type == _distanceType) distanceMeters += v;
        if (p.type == _caloriesType) calories += v;
      }
      return (distanceKm: distanceMeters / 1000.0, caloriesKcal: calories);
    } catch (e) {
      debugPrint('getTodayWalkingMetrics error: $e');
      return (distanceKm: 0.0, caloriesKcal: 0.0);
    }
  }
}
