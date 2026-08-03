import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

/// The device capabilities the app asks for before opening a picker.
enum MediaPermissionKind { camera, gallery, microphone, location }

class MediaPermissions {
  const MediaPermissions._();

  /// Ensures the requested permission is granted before proceeding.
  ///
  /// Returns true if permission is granted or limited (iOS photos).
  /// Requests the native system permission only.
  static Future<bool> ensure(
    BuildContext context,
    MediaPermissionKind kind,
  ) async {
    final PermissionStatus currentStatus = await _checkStatus(kind);

    if (currentStatus.isGranted || currentStatus.isLimited) return true;

    if (currentStatus.isRestricted || currentStatus.isPermanentlyDenied) {
      return false;
    }

    final PermissionStatus newStatus = await _request(kind);

    if (newStatus.isGranted || newStatus.isLimited) return true;

    return false;
  }

  // ── Status checking ────────────────────────────────────────────────────────

  static Future<PermissionStatus> _checkStatus(MediaPermissionKind kind) {
    return switch (kind) {
      MediaPermissionKind.camera => Permission.camera.status,
      MediaPermissionKind.microphone => Permission.microphone.status,
      MediaPermissionKind.gallery => _checkGalleryStatus(),
      MediaPermissionKind.location => Permission.locationWhenInUse.status,
    };
  }

  static Future<PermissionStatus> _checkGalleryStatus() async {
    if (!Platform.isAndroid) return Permission.photos.status;

    // Android: check both permissions
    final PermissionStatus photos = await Permission.photos.status;
    if (photos.isGranted || photos.isLimited) return photos;

    final PermissionStatus storage = await Permission.storage.status;
    return storage;
  }

  // ── Requesting ─────────────────────────────────────────────────────────────

  static Future<PermissionStatus> _request(MediaPermissionKind kind) {
    return switch (kind) {
      MediaPermissionKind.camera => Permission.camera.request(),
      MediaPermissionKind.microphone => Permission.microphone.request(),
      MediaPermissionKind.gallery => _requestGallery(),
      MediaPermissionKind.location => Permission.locationWhenInUse.request(),
    };
  }

  static Future<PermissionStatus> _requestGallery() async {
    if (!Platform.isAndroid) return Permission.photos.request();

    final PermissionStatus photos = await Permission.photos.request();
    if (photos.isGranted || photos.isLimited) return photos;

    final PermissionStatus storage = await Permission.storage.request();
    if (storage.isGranted) return storage;

    return photos.isPermanentlyDenied || storage.isPermanentlyDenied
        ? PermissionStatus.permanentlyDenied
        : PermissionStatus.denied;
  }
}
