import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitness_day/core/utils/permission_helper.dart';
import 'package:fitness_day/core/widgets/permission_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

/// Widget to pick images from camera or gallery with permission handling
class ImagePickerWidget extends StatelessWidget {
  final Function(File) onImagePicked;

  const ImagePickerWidget({
    Key? key,
    required this.onImagePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: Text('take_photo'.tr()),
          onTap: () {
            Navigator.pop(context);
            _pickImageFromCamera(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: Text('choose_from_gallery'.tr()),
          onTap: () {
            Navigator.pop(context);
            _pickImageFromGallery(context);
          },
        ),
      ],
    );
  }

  /// Pick image from camera with permission check
  Future<void> _pickImageFromCamera(BuildContext context) async {
    final result = await PermissionHelper.requestCameraWithDialog();

    if (result == PermissionRequestResult.granted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        onImagePicked(File(image.path));
      }
    } else if (result == PermissionRequestResult.permanentlyDenied) {
      if (context.mounted) {
        await PermissionDialog.showCameraPermissionDialog(context);
      }
    } else {
      if (context.mounted) {
        await PermissionDialog.showSimpleDialog(
          context: context,
          title: 'permission_denied'.tr(),
          message: 'camera_permission_denied_message'.tr(),
        );
      }
    }
  }

  /// Pick image from gallery with permission check
  Future<void> _pickImageFromGallery(BuildContext context) async {
    final result = await PermissionHelper.requestPhotosWithDialog();

    if (result == PermissionRequestResult.granted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        onImagePicked(File(image.path));
      }
    } else if (result == PermissionRequestResult.permanentlyDenied) {
      if (context.mounted) {
        await PermissionDialog.showPhotosPermissionDialog(context);
      }
    } else {
      if (context.mounted) {
        await PermissionDialog.showSimpleDialog(
          context: context,
          title: 'permission_denied'.tr(),
          message: 'photos_permission_denied_message'.tr(),
        );
      }
    }
  }

  /// Show bottom sheet to choose image source
  static Future<void> showImageSourceSheet({
    required BuildContext context,
    required Function(File) onImagePicked,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImagePickerWidget(onImagePicked: onImagePicked),
    );
  }
}
