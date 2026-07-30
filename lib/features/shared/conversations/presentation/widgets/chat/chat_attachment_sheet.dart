import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// What the user picked in the attachment sheet.
enum ChatAttachmentType { camera, gallery, video, document }

/// Bottom sheet offering the four attachment sources.
///
/// Returns the chosen [ChatAttachmentType], or null when dismissed — the page
/// runs the actual picker so the permission flow stays in one place.
Future<ChatAttachmentType?> showChatAttachmentSheet(BuildContext context) {
  FocusScope.of(context).unfocus();

  return showModalBottomSheet<ChatAttachmentType>(
    context: context,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) => const _ChatAttachmentSheet(),
  );
}

class _ChatAttachmentSheet extends StatelessWidget {
  const _ChatAttachmentSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'conversations.attachment_title'.tr(),
              style:
                  TextStyleManager.style14Bold.copyWith(color: AppColors.black),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachmentOption(
                  icon: Icons.camera_alt_rounded,
                  color: AppColors.primary,
                  label: 'conversations.attach_camera'.tr(),
                  type: ChatAttachmentType.camera,
                ),
                _AttachmentOption(
                  icon: Icons.photo_rounded,
                  color: Colors.purple,
                  label: 'conversations.attach_gallery'.tr(),
                  type: ChatAttachmentType.gallery,
                ),
                _AttachmentOption(
                  icon: Icons.videocam_rounded,
                  color: Colors.redAccent,
                  label: 'conversations.attach_video'.tr(),
                  type: ChatAttachmentType.video,
                ),
                _AttachmentOption(
                  icon: Icons.insert_drive_file_rounded,
                  color: Colors.blueAccent,
                  label: 'conversations.attach_document'.tr(),
                  type: ChatAttachmentType.document,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final ChatAttachmentType type;

  const _AttachmentOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, type),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyleManager.style10Medium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
