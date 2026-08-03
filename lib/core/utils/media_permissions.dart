import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/confirm_dialog.dart';

/// The device capabilities the app asks for before opening a picker.
enum MediaPermissionKind { camera, gallery, microphone, location }

class MediaPermissions {
  const MediaPermissions._();

  /// Ensures the requested permission is granted before proceeding.
  ///
  /// Returns true if permission is granted or limited (iOS photos).
  /// Shows appropriate dialogs for denied/blocked states.
  /// Handles all permission states: Not Determined, Granted, Denied,
  /// Restricted, and Permanently Denied.
  static Future<bool> ensure(
    BuildContext context,
    MediaPermissionKind kind, {
    bool showExplanation = false,
  }) async {
    // Check current status first
    final PermissionStatus currentStatus = await _checkStatus(kind);

    // Already granted or limited (iOS photos) - proceed
    if (currentStatus.isGranted || currentStatus.isLimited) return true;

    // Restricted (parental controls, etc.) - show explanation
    if (currentStatus.isRestricted) {
      if (!context.mounted) return false;
      await _showRestrictedDialog(context, kind);
      return false;
    }

    // Permanently denied - must go to settings
    if (currentStatus.isPermanentlyDenied) {
      if (!context.mounted) return false;
      await _showSettingsDialog(context, kind);
      return false;
    }

    // Show explanation before requesting if needed
    if (showExplanation && context.mounted) {
      final bool? shouldRequest = await _showExplanationDialog(context, kind);
      if (shouldRequest != true) return false;
      if (!context.mounted) return false;
    }

    // Request permission
    final PermissionStatus newStatus = await _request(kind);

    // iOS "limited" photo access still lets the picker run.
    if (newStatus.isGranted || newStatus.isLimited) return true;
    if (!context.mounted) return false;

    // Handle the result
    if (newStatus.isPermanentlyDenied || newStatus.isRestricted) {
      await _showSettingsDialog(context, kind);
    } else if (newStatus.isDenied) {
      showAppSnackBar(context, text: _deniedMessage(kind), isError: true);
    }
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

  // ── Dialogs ────────────────────────────────────────────────────────────────

  /// Shows an explanation dialog before requesting permission.
  static Future<bool?> _showExplanationDialog(
    BuildContext context,
    MediaPermissionKind kind,
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
    MediaPermissionKind kind,
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
    MediaPermissionKind kind,
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

  static IconData _icon(MediaPermissionKind kind) => switch (kind) {
    MediaPermissionKind.camera => Icons.camera_alt_rounded,
    MediaPermissionKind.gallery => Icons.photo_library_rounded,
    MediaPermissionKind.microphone => Icons.mic_rounded,
    MediaPermissionKind.location => Icons.location_on_rounded,
  };

  static String _explanationTitle(MediaPermissionKind kind) => switch (kind) {
    MediaPermissionKind.camera => 'permissions.camera_title'.tr(),
    MediaPermissionKind.gallery => 'permissions.gallery_title'.tr(),
    MediaPermissionKind.microphone => 'permissions.microphone_title'.tr(),
    MediaPermissionKind.location => 'permissions.location_title'.tr(),
  };

  static String _explanationMessage(MediaPermissionKind kind) => switch (kind) {
    MediaPermissionKind.camera => 'permissions.camera_explanation'.tr(),
    MediaPermissionKind.gallery => 'permissions.gallery_explanation'.tr(),
    MediaPermissionKind.microphone => 'permissions.microphone_explanation'.tr(),
    MediaPermissionKind.location => 'permissions.location_explanation'.tr(),
  };

  static String _deniedMessage(MediaPermissionKind kind) => switch (kind) {
    MediaPermissionKind.camera => 'permissions.camera_denied'.tr(),
    MediaPermissionKind.gallery => 'permissions.gallery_denied'.tr(),
    MediaPermissionKind.microphone => 'permissions.microphone_denied'.tr(),
    MediaPermissionKind.location => 'permissions.location_denied'.tr(),
  };

  static String _blockedMessage(MediaPermissionKind kind) => switch (kind) {
    MediaPermissionKind.camera => 'permissions.camera_blocked'.tr(),
    MediaPermissionKind.gallery => 'permissions.gallery_blocked'.tr(),
    MediaPermissionKind.microphone => 'permissions.microphone_blocked'.tr(),
    MediaPermissionKind.location => 'permissions.location_blocked'.tr(),
  };

  static String _restrictedMessage(MediaPermissionKind kind) => switch (kind) {
    MediaPermissionKind.camera => 'permissions.camera_restricted'.tr(),
    MediaPermissionKind.gallery => 'permissions.gallery_restricted'.tr(),
    MediaPermissionKind.microphone => 'permissions.microphone_restricted'.tr(),
    MediaPermissionKind.location => 'permissions.location_restricted'.tr(),
  };
}
