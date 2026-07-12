import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';

/// Circular image picker used on the "create challenge" screen. Lets the
/// user pick an image from the camera or gallery via a bottom sheet.
class ChallengeImagePicker extends StatefulWidget {
  final ValueChanged<File>? onImagePicked;

  const ChallengeImagePicker({super.key, this.onImagePicked});

  @override
  State<ChallengeImagePicker> createState() => _ChallengeImagePickerState();
}

class _ChallengeImagePickerState extends State<ChallengeImagePicker> {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (file != null) {
      setState(() => _pickedImage = File(file.path));
      widget.onImagePicked?.call(_pickedImage!);
    }
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _ImageSourceSheet(
        onCameraSelected: () => _pickImage(ImageSource.camera),
        onGallerySelected: () => _pickImage(ImageSource.gallery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _showSourceSheet,
        child: Column(
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: AppColors.challengeIconBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                image: _pickedImage != null
                    ? DecorationImage(image: FileImage(_pickedImage!), fit: BoxFit.cover)
                    : null,
              ),
              child: _pickedImage == null
                  ? Center(
                      child: Icon(Icons.image, color: AppColors.primary, size: 32.sp),
                    )
                  : null,
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, color: AppColors.primary, size: 14.sp),
                SizedBox(width: 4.w),
                Text(
                  _pickedImage != null
                      ? 'challenges.change_image'.tr()
                      : 'challenges.create_add_image'.tr(),
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;

  const _ImageSourceSheet({
    required this.onCameraSelected,
    required this.onGallerySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'challenges.image_source_title'.tr(),
              style: TextStyleManager.heading3.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _SourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'challenges.camera'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      onCameraSelected();
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _SourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'challenges.gallery'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      onGallerySelected();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundTint,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 30.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
