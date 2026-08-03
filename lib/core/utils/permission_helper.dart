import 'package:permission_handler/permission_handler.dart';

/// Helper class to manage app permissions for camera, photos, and microphone.
/// Provides methods to check, request, and open app settings.
class PermissionHelper {
  /// Check if camera permission is granted
  static Future<bool> isCameraGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Check if photo library permission is granted
  static Future<bool> isPhotosGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Check if microphone permission is granted
  static Future<bool> isMicrophoneGranted() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Request camera permission
  /// Returns true if granted, false otherwise
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo library permission
  /// Returns true if granted, false otherwise
  static Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Request microphone permission
  /// Returns true if granted, false otherwise
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Get camera permission status
  static Future<PermissionStatus> getCameraStatus() async {
    return await Permission.camera.status;
  }

  /// Get photo library permission status
  static Future<PermissionStatus> getPhotosStatus() async {
    return await Permission.photos.status;
  }

  /// Get microphone permission status
  static Future<PermissionStatus> getMicrophoneStatus() async {
    return await Permission.microphone.status;
  }

  /// Check if permission is permanently denied
  static Future<bool> isCameraPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Check if photos permission is permanently denied
  static Future<bool> isPhotosPermanentlyDenied() async {
    final status = await Permission.photos.status;
    return status.isPermanentlyDenied;
  }

  /// Check if microphone permission is permanently denied
  static Future<bool> isMicrophonePermanentlyDenied() async {
    final status = await Permission.microphone.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings
  /// Use this when permission is permanently denied
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Request camera permission with dialog handling
  /// Shows alert if permanently denied and offers to open settings
  static Future<PermissionRequestResult> requestCameraWithDialog() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return PermissionRequestResult.granted;
    }

    if (status.isPermanentlyDenied) {
      return PermissionRequestResult.permanentlyDenied;
    }

    final result = await Permission.camera.request();

    if (result.isGranted) {
      return PermissionRequestResult.granted;
    } else if (result.isPermanentlyDenied) {
      return PermissionRequestResult.permanentlyDenied;
    } else {
      return PermissionRequestResult.denied;
    }
  }

  /// Request photos permission with dialog handling
  /// Shows alert if permanently denied and offers to open settings
  static Future<PermissionRequestResult> requestPhotosWithDialog() async {
    final status = await Permission.photos.status;

    if (status.isGranted) {
      return PermissionRequestResult.granted;
    }

    if (status.isPermanentlyDenied) {
      return PermissionRequestResult.permanentlyDenied;
    }

    final result = await Permission.photos.request();

    if (result.isGranted) {
      return PermissionRequestResult.granted;
    } else if (result.isPermanentlyDenied) {
      return PermissionRequestResult.permanentlyDenied;
    } else {
      return PermissionRequestResult.denied;
    }
  }

  /// Request microphone permission with dialog handling
  static Future<PermissionRequestResult> requestMicrophoneWithDialog() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return PermissionRequestResult.granted;
    }

    if (status.isPermanentlyDenied) {
      return PermissionRequestResult.permanentlyDenied;
    }

    final result = await Permission.microphone.request();

    if (result.isGranted) {
      return PermissionRequestResult.granted;
    } else if (result.isPermanentlyDenied) {
      return PermissionRequestResult.permanentlyDenied;
    } else {
      return PermissionRequestResult.denied;
    }
  }
}

/// Result of permission request
enum PermissionRequestResult {
  granted,
  denied,
  permanentlyDenied,
}
