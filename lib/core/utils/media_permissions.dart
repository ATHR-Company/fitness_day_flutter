import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/confirm_dialog.dart';

/// The device capabilities the app asks for before opening a picker.
enum MediaPermissionKind { camera, gallery, microphone }

class MediaPermissions {
  const MediaPermissions._();

  static Future<bool> ensure(
    BuildContext context,
    MediaPermissionKind kind,
  ) async {
    final PermissionStatus status = await _request(kind);

    // iOS "limited" photo access still lets the picker run.
    if (status.isGranted || status.isLimited) return true;
    if (!context.mounted) return false;

    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showSettingsDialog(context, kind);
    } else {
      showAppSnackBar(context, text: _deniedMessage(kind), isError: true);
    }
    return false;
  }

  // ── Requesting ─────────────────────────────────────────────────────────────

  static Future<PermissionStatus> _request(MediaPermissionKind kind) {
    return switch (kind) {
      MediaPermissionKind.camera => Permission.camera.request(),
      MediaPermissionKind.microphone => Permission.microphone.request(),
      MediaPermissionKind.gallery => _requestGallery(),
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

  // ── Messaging ──────────────────────────────────────────────────────────────

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

  static IconData _icon(MediaPermissionKind kind) => switch (kind) {
        MediaPermissionKind.camera => Icons.no_photography_rounded,
        MediaPermissionKind.gallery => Icons.photo_library_rounded,
        MediaPermissionKind.microphone => Icons.mic_off_rounded,
      };

  static String _deniedMessage(MediaPermissionKind kind) => switch (kind) {
        MediaPermissionKind.camera => 'permissions.camera_denied'.tr(),
        MediaPermissionKind.gallery => 'permissions.gallery_denied'.tr(),
        MediaPermissionKind.microphone =>
          'permissions.microphone_denied'.tr(),
      };

  static String _blockedMessage(MediaPermissionKind kind) => switch (kind) {
        MediaPermissionKind.camera => 'permissions.camera_blocked'.tr(),
        MediaPermissionKind.gallery => 'permissions.gallery_blocked'.tr(),
        MediaPermissionKind.microphone =>
          'permissions.microphone_blocked'.tr(),
      };
}
