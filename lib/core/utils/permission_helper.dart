import 'dart:io';

import 'package:permission_handler/permission_handler.dart' as ph;

/// Helper class to manage app permissions for camera, photos, and microphone.
/// Provides methods to check, request, and open app settings.
class PermissionHelper {
  /// Check if camera permission is granted
  static Future<bool> isCameraGranted() async {
    final status = await ph.Permission.camera.status;
    return status.isGranted;
  }

  /// Check if photo library permission is granted
  static Future<bool> isPhotosGranted() async {
    final status = await getPhotosStatus();
    return status.isGranted || status.isLimited;
  }

  /// Check if microphone permission is granted
  static Future<bool> isMicrophoneGranted() async {
    final status = await ph.Permission.microphone.status;
    return status.isGranted;
  }

  /// Request camera permission
  /// Returns true if granted, false otherwise
  static Future<bool> requestCamera() async {
    final status = await ph.Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo library permission
  /// Returns true if granted, false otherwise
  static Future<bool> requestPhotos() async {
    final status = await _requestPhotos();
    return status.isGranted || status.isLimited;
  }

  /// Request microphone permission
  /// Returns true if granted, false otherwise
  static Future<bool> requestMicrophone() async {
    final status = await ph.Permission.microphone.request();
    return status.isGranted;
  }

  /// Get camera permission status
  static Future<ph.PermissionStatus> getCameraStatus() async {
    return await ph.Permission.camera.status;
  }

  /// Get photo library permission status
  static Future<ph.PermissionStatus> getPhotosStatus() async {
    if (!Platform.isAndroid) return ph.Permission.photos.status;

    final photos = await ph.Permission.photos.status;
    if (photos.isGranted || photos.isLimited) return photos;

    return ph.Permission.storage.status;
  }

  /// Get microphone permission status
  static Future<ph.PermissionStatus> getMicrophoneStatus() async {
    return await ph.Permission.microphone.status;
  }

  /// Check if permission is permanently denied
  static Future<bool> isCameraPermanentlyDenied() async {
    final status = await ph.Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Check if photos permission is permanently denied
  static Future<bool> isPhotosPermanentlyDenied() async {
    final status = await getPhotosStatus();
    return status.isPermanentlyDenied;
  }

  /// Check if microphone permission is permanently denied
  static Future<bool> isMicrophonePermanentlyDenied() async {
    final status = await ph.Permission.microphone.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings
  /// Use this when permission is permanently denied
  static Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }

  /// Request camera permission with dialog handling
  /// Shows alert if permanently denied and offers to open settings
  static Future<PermissionRequestResult> requestCameraWithDialog() async {
    final status = await ph.Permission.camera.status;

    if (status.isGranted) {
      return PermissionRequestResult.granted;
    }

    if (status.isPermanentlyDenied) {
      return PermissionRequestResult.permanentlyDenied;
    }

    final result = await ph.Permission.camera.request();

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
    final status = await getPhotosStatus();

    if (status.isGranted || status.isLimited) {
      return PermissionRequestResult.granted;
    }

    if (status.isPermanentlyDenied) {
      return PermissionRequestResult.permanentlyDenied;
    }

    final result = await _requestPhotos();

    if (result.isGranted || result.isLimited) {
      return PermissionRequestResult.granted;
    } else if (result.isPermanentlyDenied) {
      return PermissionRequestResult.permanentlyDenied;
    } else {
      return PermissionRequestResult.denied;
    }
  }

  /// Request microphone permission with dialog handling
  static Future<PermissionRequestResult> requestMicrophoneWithDialog() async {
    final status = await ph.Permission.microphone.status;

    if (status.isGranted) {
      return PermissionRequestResult.granted;
    }

    if (status.isPermanentlyDenied) {
      return PermissionRequestResult.permanentlyDenied;
    }

    final result = await ph.Permission.microphone.request();

    if (result.isGranted) {
      return PermissionRequestResult.granted;
    } else if (result.isPermanentlyDenied) {
      return PermissionRequestResult.permanentlyDenied;
    } else {
      return PermissionRequestResult.denied;
    }
  }

  static Future<ph.PermissionStatus> _requestPhotos() async {
    if (!Platform.isAndroid) return ph.Permission.photos.request();

    final photos = await ph.Permission.photos.request();
    if (photos.isGranted || photos.isLimited) return photos;

    final storage = await ph.Permission.storage.request();
    if (storage.isGranted) return storage;

    return photos.isPermanentlyDenied || storage.isPermanentlyDenied
        ? ph.PermissionStatus.permanentlyDenied
        : ph.PermissionStatus.denied;
  }
}

/// Result of permission request
enum PermissionRequestResult { granted, denied, permanentlyDenied }
