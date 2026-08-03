import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permissions needed for activity tracking (Running and Walking).
enum ActivityPermissionKind { location, motion }

class ActivityPermissions {
  const ActivityPermissions._();

  /// Ensures both Location and Motion permissions are granted for running activities.
  ///
  /// Returns true only if both permissions are granted.
  /// Requests native system permissions only.
  static Future<bool> ensureRunningPermissions(BuildContext context) async {
    final bool motionGranted = await ensureMotion(context);
    if (!motionGranted) return false;
    if (!context.mounted) return false;

    final bool locationGranted = await ensureLocation(context);
    return locationGranted;
  }

  /// Ensures Location permission is granted.
  ///
  /// Returns true if permission is granted.
  /// Requests the native system permission only.
  static Future<bool> ensureLocation(BuildContext context) async {
    final LocationPermission currentStatus = await Geolocator.checkPermission();

    if (currentStatus == LocationPermission.always ||
        currentStatus == LocationPermission.whileInUse) {
      return true;
    }

    if (currentStatus == LocationPermission.deniedForever) {
      return false;
    }

    final LocationPermission newStatus = await Geolocator.requestPermission();

    return newStatus == LocationPermission.always ||
        newStatus == LocationPermission.whileInUse;
  }

  /// Ensures Motion/Sensors permission is granted.
  ///
  /// Returns true if permission is granted.
  /// Requests the native system permission only.
  static Future<bool> ensureMotion(BuildContext context) async {
    final Permission motion = defaultTargetPlatform == TargetPlatform.iOS
        ? Permission.sensors
        : Permission.activityRecognition;

    final PermissionStatus currentStatus = await motion.status;

    if (currentStatus.isGranted) return true;

    if (currentStatus.isRestricted || currentStatus.isPermanentlyDenied) {
      return false;
    }

    final PermissionStatus newStatus = await motion.request();

    return newStatus.isGranted;
  }

  /// Checks if Location permission is granted without requesting.
  static Future<bool> isLocationGranted() async {
    final LocationPermission status = await Geolocator.checkPermission();
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  /// Checks if Motion permission is granted without requesting.
  static Future<bool> isMotionGranted() async {
    final Permission motion = defaultTargetPlatform == TargetPlatform.iOS
        ? Permission.sensors
        : Permission.activityRecognition;
    final PermissionStatus status = await motion.status;
    return status.isGranted;
  }

  /// Checks if both Location and Motion permissions are granted.
  static Future<bool> areRunningPermissionsGranted() async {
    final bool locationGranted = await isLocationGranted();
    if (!locationGranted) return false;
    return await isMotionGranted();
  }
}
