import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';

/// Shows a dialog to inform user about permission denial
/// and offers to open app settings
class PermissionDialog {
  /// Show dialog for camera permission
  static Future<void> showCameraPermissionDialog(BuildContext context) async {
    return _showPermissionDialog(
      context: context,
      title: 'camera_permission_required'.tr(),
      message: 'camera_permission_message'.tr(),
    );
  }

  /// Show dialog for photos permission
  static Future<void> showPhotosPermissionDialog(BuildContext context) async {
    return _showPermissionDialog(
      context: context,
      title: 'photos_permission_required'.tr(),
      message: 'photos_permission_message'.tr(),
    );
  }

  /// Show dialog for microphone permission
  static Future<void> showMicrophonePermissionDialog(
      BuildContext context) async {
    return _showPermissionDialog(
      context: context,
      title: 'microphone_permission_required'.tr(),
      message: 'microphone_permission_message'.tr(),
    );
  }

  /// Generic permission dialog
  static Future<void> _showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('open_settings'.tr()),
            ),
          ],
        );
      },
    );
  }

  /// Show simple alert dialog
  static Future<void> showSimpleDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ok'.tr()),
            ),
          ],
        );
      },
    );
  }
}
