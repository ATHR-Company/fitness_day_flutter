import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';

/// The device capabilities the app asks for before opening a picker.
enum MediaPermissionKind { camera, gallery, microphone, location }

class MediaPermissions {
  const MediaPermissions._();

  /// Ensures the requested permission is granted before proceeding.
  ///
  /// Returns true when granted, or limited (a partial photo grant).
  ///
  /// ### Why asking for [MediaPermissionKind.gallery] is safe again
  ///
  /// The picker and the permission are deliberately decoupled. `image_picker`
  /// runs on `ACTION_PICK_IMAGES` on Android (see `configureMediaPickers`) and
  /// on `PHPickerViewController` on iOS; both pick out of process and return a
  /// per-item grant, so neither reads this permission.
  ///
  /// That is what keeps the original bug fixed. Before, the app queried
  /// MediaStore itself, so answering "Select photos" pinned it to the subset
  /// granted the first time and later selections were silently ignored. Now the
  /// answer changes nothing about what the picker shows — a `limited` grant
  /// still browses the full library.
  static Future<bool> ensure(
    BuildContext context,
    MediaPermissionKind kind,
  ) async {
    final Permission permission = _permissionFor(kind);
    final PermissionStatus current = await permission.status;

    if (current.isGranted || current.isLimited) return true;

    // Nothing left to ask — the OS will not show the dialog again, so the only
    // way out is the app's settings page.
    if (current.isRestricted || current.isPermanentlyDenied) {
      if (context.mounted) await _offerSettings(context, kind);
      return false;
    }

    final PermissionStatus updated = await permission.request();

    if (updated.isGranted || updated.isLimited) return true;

    // A picker that just closes on refusal looks broken; say what was refused.
    if (context.mounted) {
      showAppSnackBar(context, text: _deniedMessage(kind), isError: true);
    }
    return false;
  }

  static Permission _permissionFor(MediaPermissionKind kind) {
    return switch (kind) {
      MediaPermissionKind.camera => Permission.camera,
      MediaPermissionKind.microphone => Permission.microphone,
      MediaPermissionKind.gallery => Permission.photos,
      MediaPermissionKind.location => Permission.locationWhenInUse,
    };
  }

  static String _deniedMessage(MediaPermissionKind kind) => switch (kind) {
        MediaPermissionKind.camera =>
          'image_picker.camera_permission_denied_message'.tr(),
        MediaPermissionKind.gallery =>
          'image_picker.photos_permission_denied_message'.tr(),
        MediaPermissionKind.microphone =>
          'image_picker.microphone_permission_message'.tr(),
        MediaPermissionKind.location =>
          'permissions_settings.permission_denied'.tr(),
      };

  static ({String title, String body}) _rationale(MediaPermissionKind kind) =>
      switch (kind) {
        MediaPermissionKind.camera => (
            title: 'image_picker.camera_permission_required'.tr(),
            body: 'image_picker.camera_permission_message'.tr(),
          ),
        MediaPermissionKind.gallery => (
            title: 'image_picker.photos_permission_required'.tr(),
            body: 'image_picker.photos_permission_message'.tr(),
          ),
        MediaPermissionKind.microphone => (
            title: 'image_picker.microphone_permission_required'.tr(),
            body: 'image_picker.microphone_permission_message'.tr(),
          ),
        MediaPermissionKind.location => (
            title: 'permissions_settings.permission_denied'.tr(),
            body: 'permissions_settings.permissions_info'.tr(),
          ),
      };

  static Future<void> _offerSettings(
    BuildContext context,
    MediaPermissionKind kind,
  ) async {
    final rationale = _rationale(kind);
    final bool? go = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(rationale.title, style: TextStyleManager.heading3),
        content: Text(
          rationale.body,
          style: TextStyleManager.style11Medium
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'image_picker.cancel'.tr(),
              style: TextStyleManager.smallButtons
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'image_picker.open_settings'.tr(),
              style:
                  TextStyleManager.smallButtons.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (go ?? false) await openAppSettings();
  }
}
