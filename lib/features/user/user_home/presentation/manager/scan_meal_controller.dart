import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fitness_day/core/constant/app_env.dart';
import 'package:fitness_day/features/user/user_home/data/datasources/openrouter_meal_service.dart';
import 'package:fitness_day/features/user/user_home/data/models/meal_analysis_model.dart';

/// What the scan screen is currently able to show.
enum ScanMealStatus { loading, ready, permissionDenied, cameraFailed }

/// Owns the camera session and the analysis call behind the scan-meal screen.
///
/// Keeping the state machine here leaves the screen as pure composition: it
/// reads [status] / [isAnalyzing] and renders, rather than juggling a
/// controller, a permission request and a lifecycle observer inline.
class ScanMealController extends ChangeNotifier {
  /// The key is resolved at runtime from `.env` (falling back to
  /// `--dart-define`). Never hardcode secrets — see `core/constant/app_env.dart`.
  ScanMealController({OpenRouterMealService? mealService})
      : _mealService = mealService ??
            OpenRouterMealService(apiKey: AppEnv.openRouterApiKey);

  final OpenRouterMealService _mealService;

  CameraController? _camera;
  ScanMealStatus _status = ScanMealStatus.loading;
  bool _isAnalyzing = false;
  bool _disposed = false;

  CameraController? get camera => _camera;
  ScanMealStatus get status => _status;
  bool get isAnalyzing => _isAnalyzing;

  /// True only when there is a live preview to draw on.
  bool get isPreviewLive =>
      _status == ScanMealStatus.ready &&
      (_camera?.value.isInitialized ?? false);

  // ── Camera lifecycle ───────────────────────────────────────────────────────

  Future<void> initCamera() async {
    _setStatus(ScanMealStatus.loading);

    if (!await Permission.camera.request().isGranted) {
      _setStatus(ScanMealStatus.permissionDenied);
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('no_cameras', 'No cameras');

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();

      if (_disposed) {
        await controller.dispose();
        return;
      }
      _camera = controller;
      _setStatus(ScanMealStatus.ready);
    } catch (e) {
      debugPrint('[ScanMealController] camera init failed: $e');
      _setStatus(ScanMealStatus.cameraFailed);
    }
  }

  /// Releases the camera when the app goes to the background and rebuilds it
  /// on the way back.
  ///
  /// We wait for [AppLifecycleState.paused] — not [AppLifecycleState.inactive]
  /// — before tearing down the camera. `inactive` fires for transient overlays
  /// (notification shade, incoming call banner, permission dialogs) which
  /// would kill the preview unnecessarily. `paused` means the app is truly in
  /// the background / off-screen.
  ///
  /// On `resumed` we guard against a double-init: if the camera is already
  /// initialised (e.g. the app was only briefly interrupted via `inactive`
  /// without ever reaching `paused`) we skip the rebuild entirely.
  Future<void> handleAppLifecycle(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      // App is now in the background — release the camera so other apps
      // (and the OS) can use it, and stop drawing the preview.
      final controller = _camera;
      if (controller == null) return;
      _camera = null;
      _setStatus(ScanMealStatus.loading);
      await controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Only rebuild if the camera was actually torn down (i.e. we went
      // through `paused`).  If the camera is already live we do nothing —
      // this avoids a redundant re-init after a brief `inactive` event such
      // as swiping down the notification shade.
      final alreadyLive =
          _camera != null && (_camera?.value.isInitialized ?? false);
      if (!alreadyLive) {
        await initCamera();
      }
    }
  }

  // ── Capture & analysis ─────────────────────────────────────────────────────

  /// Takes a photo and runs it through the vision model.
  ///
  /// Returns null when the camera isn't ready or a capture is already running.
  /// Throws [MealAnalysisException] when the analysis itself fails, so the
  /// screen can show the reason.
  Future<MealAnalysisResult?> captureAndAnalyze() async {
    final controller = _camera;
    if (!isPreviewLive || controller == null || _isAnalyzing) return null;

    _isAnalyzing = true;
    _notify();
    try {
      final XFile photo = await controller.takePicture();
      return await _mealService.analyzeMeal(File(photo.path));
    } finally {
      _isAnalyzing = false;
      _notify();
    }
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  void _setStatus(ScanMealStatus status) {
    _status = status;
    _notify();
  }

  /// A camera callback that lands after the screen is gone must not notify.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _camera?.dispose();
    _camera = null;
    super.dispose();
  }
}
