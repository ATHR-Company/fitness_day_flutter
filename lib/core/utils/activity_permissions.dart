import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/confirm_dialog.dart';

/// Permissions needed for activity tracking (Running and Walking).
enum ActivityPermissionKind { location, motion }

class ActivityPermissions {
  const ActivityPermissions._();

  /// Ensures both Location and Motion permissions are granted for running activities.
  ///
  /// Returns true only if both permissions are granted.
  /// Shows appropriate dialogs for denied/blocked states.
  static Future<bool> ensureRunningPermissions(
    BuildContext context, {
    bool showExplanation = true,
  }) async {
    // Show explanation before requesting if needed
    if (showExplanation && context.mounted) {
      final bool? shouldRequest = await _showRunningExplanationDialog(context);
      if (shouldRequest != true) return false;
      if (!context.mounted) return false;
    }

    // Request motion permission first
    final bool motionGranted = await ensureMotion(
      context,
      showExplanation: false,
    );
    if (!motionGranted) return false;
    if (!context.mounted) return false;

    // Then request location permission
    final bool locationGranted = await ensureLocation(
      context,
      showExplanation: false,
    );
    return locationGranted;
  }

  /// Ensures Location permission is granted.
  ///
  /// Returns true if permission is granted.
  /// Shows appropriate dialogs for denied/blocked states.
  static Future<bool> ensureLocation(
    BuildContext context, {
    bool showExplanation = false,
  }) async {
    // Check current status first
    final LocationPermission currentStatus = await Geolocator.checkPermission();

    // Already granted - proceed
    if (currentStatus == LocationPermission.always ||
        currentStatus == LocationPermission.whileInUse) {
      return true;
    }

    // Permanently denied - must go to settings
    if (currentStatus == LocationPermission.deniedForever) {
      if (!context.mounted) return false;
      await _showSettingsDialog(context, ActivityPermissionKind.location);
      return false;
    }

    // Show explanation before requesting if needed
    if (showExplanation && context.mounted) {
      final bool? shouldRequest = await _showExplanationDialog(
        context,
        ActivityPermissionKind.location,
      );
      if (shouldRequest != true) return false;
      if (!context.mounted) return false;
    }

    // Request permission
    final LocationPermission newStatus = await Geolocator.requestPermission();

    // Check result
    if (newStatus == LocationPermission.always ||
        newStatus == LocationPermission.whileInUse) {
      return true;
    }

    if (!context.mounted) return false;

    // Handle the result
    if (newStatus == LocationPermission.deniedForever) {
      await _showSettingsDialog(context, ActivityPermissionKind.location);
    } else {
      showAppSnackBar(
        context,
        text: 'permissions.location_denied'.tr(),
        isError: true,
      );
    }
    return false;
  }

  /// Ensures Motion/Sensors permission is granted.
  ///
  /// Returns true if permission is granted.
  /// Shows appropriate dialogs for denied/blocked states.
  static Future<bool> ensureMotion(
    BuildContext context, {
    bool showExplanation = false,
  }) async {
    final Permission motion = defaultTargetPlatform == TargetPlatform.iOS
        ? Permission.sensors
        : Permission.activityRecognition;

    // Check current status first
    final PermissionStatus currentStatus = await motion.status;

    // Already granted - proceed
    if (currentStatus.isGranted) return true;

    // Restricted (parental controls, etc.) - show explanation
    if (currentStatus.isRestricted) {
      if (!context.mounted) return false;
      await _showRestrictedDialog(context, ActivityPermissionKind.motion);
      return false;
    }

    // Permanently denied - must go to settings
    if (currentStatus.isPermanentlyDenied) {
      if (!context.mounted) return false;
      await _showSettingsDialog(context, ActivityPermissionKind.motion);
      return false;
    }

    // Show explanation before requesting if needed
    if (showExplanation && context.mounted) {
      final bool? shouldRequest = await _showExplanationDialog(
        context,
        ActivityPermissionKind.motion,
      );
      if (shouldRequest != true) return false;
      if (!context.mounted) return false;
    }

    // Request permission
    final PermissionStatus newStatus = await motion.request();

    // Check result
    if (newStatus.isGranted) return true;
    if (!context.mounted) return false;

    // Handle the result
    if (newStatus.isPermanentlyDenied || newStatus.isRestricted) {
      await _showSettingsDialog(context, ActivityPermissionKind.motion);
    } else {
      showAppSnackBar(
        context,
        text: 'permissions.motion_denied'.tr(),
        isError: true,
      );
    }
    return false;
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

  // ── Dialogs ────────────────────────────────────────────────────────────────

  /// Shows an explanation dialog before requesting permission.
  static Future<bool?> _showRunningExplanationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        icon: Icons.directions_run_rounded,
        title: 'activity_tracking.running_title'.tr(),
        subtitle: 'permissions.running_explanation'.tr(),
        confirmText: 'permissions.allow'.tr(),
        cancelText: 'permissions.not_now'.tr(),
        accentColor: AppColors.primary,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  /// Shows an explanation dialog before requesting permission.
  static Future<bool?> _showExplanationDialog(
    BuildContext context,
    ActivityPermissionKind kind,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        icon: _icon(kind),
        title: _explanationTitle(kind),
        subtitle: _explanationMessage(kind),
        confirmText: 'permissions.allow'.tr(),
        cancelText: 'permissions.not_now'.tr(),
        accentColor: AppColors.primary,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  /// Shows a dialog when permission is permanently denied, offering to open settings.
  static Future<void> _showSettingsDialog(
    BuildContext context,
    ActivityPermissionKind kind,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        icon: _icon(kind),
        title: 'permissions.blocked_title'.tr(),
        subtitle: _blockedMessage(kind),
        confirmText: 'permissions.open_settings'.tr(),
        cancelText: 'permissions.cancel'.tr(),
        accentColor: AppColors.primary,
        onConfirm: openAppSettings,
      ),
    );
  }

  /// Shows a dialog when permission is restricted (e.g., parental controls).
  static Future<void> _showRestrictedDialog(
    BuildContext context,
    ActivityPermissionKind kind,
  ) {
    return showDialog<void>(
      context: context,
      builder: (_) => ConfirmDialog(
        icon: _icon(kind),
        title: 'permissions.restricted_title'.tr(),
        subtitle: _restrictedMessage(kind),
        confirmText: 'permissions.ok'.tr(),
        cancelText: 'permissions.cancel'.tr(),
        accentColor: AppColors.primary,
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  static IconData _icon(ActivityPermissionKind kind) => switch (kind) {
    ActivityPermissionKind.location => Icons.location_on_rounded,
    ActivityPermissionKind.motion => Icons.directions_walk_rounded,
  };

  static String _explanationTitle(ActivityPermissionKind kind) =>
      switch (kind) {
        ActivityPermissionKind.location => 'permissions.location_title'.tr(),
        ActivityPermissionKind.motion => 'permissions.motion_title'.tr(),
      };

  static String _explanationMessage(ActivityPermissionKind kind) =>
      switch (kind) {
        ActivityPermissionKind.location =>
          'permissions.location_explanation'.tr(),
        ActivityPermissionKind.motion => 'permissions.motion_explanation'.tr(),
      };

  static String _blockedMessage(ActivityPermissionKind kind) => switch (kind) {
    ActivityPermissionKind.location => 'permissions.location_blocked'.tr(),
    ActivityPermissionKind.motion => 'permissions.motion_blocked'.tr(),
  };

  static String _restrictedMessage(ActivityPermissionKind kind) =>
      switch (kind) {
        ActivityPermissionKind.location =>
          'permissions.location_restricted'.tr(),
        ActivityPermissionKind.motion => 'permissions.motion_restricted'.tr(),
      };
}
