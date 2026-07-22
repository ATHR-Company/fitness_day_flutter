import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper over [connectivity_plus] exposing a simple online/offline
/// boolean stream. NOTE: this reflects the device's network *interface*
/// (wifi/mobile/none), not whether the internet is actually reachable — a
/// failed request mapped to a `NetworkFailure` remains the source of truth
/// for per-request errors ([NetworkErrorView]).
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  /// Emits `true` when online, `false` when the device has no network.
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_isOnline);

  Future<bool> get isOnline async =>
      _isOnline(await _connectivity.checkConnectivity());
}
