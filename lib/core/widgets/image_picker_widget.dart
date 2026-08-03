import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/utils/media_permissions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget to pick images from camera or gallery with permission handling
class ImagePickerWidget extends StatelessWidget {
  final Function(File) onImagePicked;

  const ImagePickerWidget({super.key, required this.onImagePicked});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: Text('image_picker.take_photo'.tr()),
          onTap: () {
            Navigator.pop(context);
            _pickImageFromCamera(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: Text('image_picker.choose_from_gallery'.tr()),
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
    await _pickImage(context, ImageSource.camera, MediaPermissionKind.camera);
  }

  /// Pick image from gallery with permission check
  Future<void> _pickImageFromGallery(BuildContext context) async {
    await _pickImage(context, ImageSource.gallery, MediaPermissionKind.gallery);
  }

  Future<void> _pickImage(
    BuildContext context,
    ImageSource source,
    MediaPermissionKind permissionKind,
  ) async {
    final granted = await MediaPermissions.ensure(context, permissionKind);
    if (!granted || !context.mounted) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      onImagePicked(File(image.path));
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
