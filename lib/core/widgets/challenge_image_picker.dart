import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/utils/media_permissions.dart';
import 'package:fitness_day/core/widgets/image_source_sheet.dart';
import 'package:fitness_day/core/widgets/full_screen_image_view.dart';

/// Circular image picker used in create-challenge and edit-profile screens.
///
/// When [showEditOverlay] is true (profile pickers):
/// - **Tap on the edit badge** → opens [ImageSourceSheet] to pick from
///   camera or gallery.
/// - **Tap on the image** → opens [FullScreenImageView] for the currently
///   displayed image (falls back to the source sheet if there's no image).
///
/// Otherwise (e.g. create-challenge):
/// - **Tap** → opens [ImageSourceSheet] to pick from camera or gallery.
/// - **Long-press** (when an image is already set) → opens
///   [FullScreenImageView] for the currently displayed image.
class ChallengeImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final ValueChanged<File>? onImagePicked;
  final bool showBottomText;
  final bool showEditOverlay;
  final double? size;

  const ChallengeImagePicker({
    super.key,
    this.initialImageUrl,
    this.onImagePicked,
    this.showBottomText = true,
    this.showEditOverlay = false,
    this.size,
  });

  @override
  State<ChallengeImagePicker> createState() => _ChallengeImagePickerState();
}

class _ChallengeImagePickerState extends State<ChallengeImagePicker> {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // ── Image picking ─────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final bool granted = await MediaPermissions.ensure(
      context,
      source == ImageSource.camera
          ? MediaPermissionKind.camera
          : MediaPermissionKind.gallery,
    );
    if (!granted || !mounted) return;

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
      builder: (_) => ImageSourceSheet(
        onCameraSelected: () => _pickImage(ImageSource.camera),
        onGallerySelected: () => _pickImage(ImageSource.gallery),
      ),
    );
  }

  // ── Full-screen viewer ────────────────────────────────────────────────────

  bool get _hasImage =>
      _pickedImage != null ||
      (widget.initialImageUrl?.isNotEmpty ?? false);

  void _openFullScreen() {
    if (!_hasImage) return;
    FullScreenImageView.show(
      context,
      imageFile: _pickedImage,
      imageUrl: _pickedImage == null ? widget.initialImageUrl : null,
      heroTag: 'challenge_image_picker_${widget.hashCode}',
    );
  }

  void _onImageTap() {
    if (widget.showEditOverlay) {
      if (_hasImage) {
        _openFullScreen();
      } else {
        _showSourceSheet();
      }
    } else {
      _showSourceSheet();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? 90.w;
    final String networkAvatar = widget.initialImageUrl ?? '';
    final bool hasImage = _pickedImage != null || networkAvatar.isNotEmpty;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            // Tap → view full-screen (profile) or pick a new image (challenge)
            onTap: _onImageTap,
            // Long-press → view current image full-screen (challenge picker
            // only; the profile picker already opens it on tap)
            onLongPress: (!widget.showEditOverlay && hasImage) ? _openFullScreen : null,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Avatar circle ──────────────────────────────────────
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppColors.challengeIconBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    image: _pickedImage != null
                        ? DecorationImage(
                            image: FileImage(_pickedImage!),
                            fit: BoxFit.cover,
                          )
                        : (networkAvatar.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(networkAvatar),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  // Placeholder icon when nothing is selected
                  child: (!hasImage)
                      ? Center(
                          child: Icon(
                            widget.showEditOverlay
                                ? Icons.person
                                : Icons.image,
                            color: AppColors.primary,
                            size: (size * 0.35).sp,
                          ),
                        )
                      : null,
                ),

                // ── Edit overlay badge ─────────────────────────────────
                if (widget.showEditOverlay)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: GestureDetector(
                      onTap: _showSourceSheet,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: AppColors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
