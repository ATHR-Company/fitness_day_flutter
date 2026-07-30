import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/scan_meal_controller.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/scan_meal/scan_meal_analyzing_overlay.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/scan_meal/scan_meal_frame_overlay.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/scan_meal/scan_meal_status_view.dart';

/// The black area under the app bar: whichever of the live preview, the
/// spinner or a recovery message the current [ScanMealStatus] calls for.
class ScanMealCameraArea extends StatelessWidget {
  final ScanMealController controller;

  /// Retries camera start-up after a failure.
  final VoidCallback onRetry;

  const ScanMealCameraArea({
    super.key,
    required this.controller,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildForStatus(),
          if (controller.isAnalyzing) const ScanMealAnalyzingOverlay(),
        ],
      ),
    );
  }

  Widget _buildForStatus() {
    return switch (controller.status) {
      ScanMealStatus.loading => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ScanMealStatus.permissionDenied => ScanMealStatusView(
          icon: Icons.no_photography_rounded,
          message: 'permissions.camera_blocked'.tr(),
          actionLabel: 'permissions.open_settings'.tr(),
          onAction: openAppSettings,
        ),
      ScanMealStatus.cameraFailed => ScanMealStatusView(
          icon: Icons.error_outline_rounded,
          message: 'scan_meal.camera_failed'.tr(),
          actionLabel: 'scan_meal.retry'.tr(),
          onAction: onRetry,
        ),
      ScanMealStatus.ready => _buildPreview(),
    };
  }

  Widget _buildPreview() {
    final camera = controller.camera;
    if (camera == null || !controller.isPreviewLive) {
      return const SizedBox.shrink();
    }

    // The preview reports its size in sensor orientation, so width/height are
    // swapped before letting FittedBox crop it to the screen.
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: camera.value.previewSize?.height ?? 1,
            height: camera.value.previewSize?.width ?? 1,
            child: CameraPreview(camera),
          ),
        ),
        const ScanMealFrameOverlay(),
      ],
    );
  }
}
