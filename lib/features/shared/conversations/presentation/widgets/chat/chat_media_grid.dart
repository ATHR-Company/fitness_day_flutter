import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';
import 'package:fitness_day/features/shared/conversations/presentation/utils/chat_attachment_viewer.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_audio_bubble.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_video_thumbnail.dart';

/// Media area of a chat bubble.
///
///   - 1 attachment  → full-width image / video / voice note / document row
///   - 2 attachments → side by side
///   - 3+            → 2-column grid, with a "+N" overlay on the last cell
class ChatMediaGrid extends StatelessWidget {
  /// How many cells the grid shows before collapsing the rest into "+N".
  static const int _maxVisible = 4;

  final List<ChatMediaAttachment> attachments;

  /// Only used to colour the voice-note bubble of a single audio attachment.
  final bool isMine;

  const ChatMediaGrid({
    super.key,
    required this.attachments,
    this.isMine = true,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    if (attachments.length == 1) {
      return _SingleAttachment(attachment: attachments.first, isMine: isMine);
    }

    final visible = attachments.take(_maxVisible).toList();
    final int hidden = attachments.length - visible.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visible.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 2.w,
          crossAxisSpacing: 2.w,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final attachment = visible[index];
          final bool isOverflowCell = hidden > 0 && index == visible.length - 1;

          return GestureDetector(
            onTap: () => openChatAttachment(context, attachment),
            child: isOverflowCell
                ? _OverflowCell(attachment: attachment, hiddenCount: hidden)
                : _GridCell(attachment: attachment),
          );
        },
      ),
    );
  }
}

// ── Single attachment ────────────────────────────────────────────────────────

class _SingleAttachment extends StatelessWidget {
  final ChatMediaAttachment attachment;
  final bool isMine;

  const _SingleAttachment({required this.attachment, required this.isMine});

  @override
  Widget build(BuildContext context) {
    if (attachment.isAudio) {
      return ChatAudioBubble(
        source: attachment.url,
        isNetwork: !attachment.isLocal,
      );
    }

    return GestureDetector(
      onTap: () => openChatAttachment(context, attachment),
      behavior: HitTestBehavior.opaque,
      child: attachment.isImage
          ? _ImagePreview(attachment: attachment)
          : attachment.isVideo
              ? _VideoPreview(attachment: attachment)
              // Anything that isn't image/video/audio is drawn as a document
              // row — that covers `document` and the legacy `file` type.
              : _DocumentRow(attachment: attachment),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final ChatMediaAttachment attachment;

  const _ImagePreview({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(
        width: 200.w,
        height: 200.w,
        child: _AttachmentImage(attachment: attachment),
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  final ChatMediaAttachment attachment;

  const _VideoPreview({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(
        width: 200.w,
        height: 150.w,
        child: ChatVideoThumbnail(
          source: attachment.url,
          isNetwork: !attachment.isLocal,
        ),
      ),
    );
  }
}

/// PDF / document row — tapping it opens the native app, or the in-app WebView
/// when nothing on the device can handle the file.
class _DocumentRow extends StatelessWidget {
  final ChatMediaAttachment attachment;

  const _DocumentRow({required this.attachment});

  @override
  Widget build(BuildContext context) {
    // The server's title, not the URL: the stored file is renamed to a UUID, so
    // reading the name off the URL showed the recipient `f3c2a1b4-....pdf`
    // while the sender's own optimistic bubble still had the real name.
    final String fileName = attachment.displayName;
    final bool isPdf = fileName.toLowerCase().endsWith('.pdf') ||
        attachment.mimeType == 'application/pdf';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPdf
                ? Icons.picture_as_pdf_rounded
                : Icons.insert_drive_file_rounded,
            color: isPdf ? Colors.redAccent : AppColors.primary,
            size: 24.sp,
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyleManager.style11Medium,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.open_in_new_rounded,
              color: AppColors.textSecondary, size: 15.sp),
        ],
      ),
    );
  }
}

// ── Grid cells ───────────────────────────────────────────────────────────────

class _GridCell extends StatelessWidget {
  final ChatMediaAttachment attachment;

  const _GridCell({required this.attachment});

  @override
  Widget build(BuildContext context) {
    if (attachment.isImage) return _AttachmentImage(attachment: attachment);

    if (attachment.isVideo) {
      return ChatVideoThumbnail(
        source: attachment.url,
        isNetwork: !attachment.isLocal,
        playIconSize: 36,
      );
    }

    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Icon(Icons.insert_drive_file_rounded,
          color: AppColors.primary, size: 32.sp),
    );
  }
}

class _OverflowCell extends StatelessWidget {
  final ChatMediaAttachment attachment;
  final int hiddenCount;

  const _OverflowCell({required this.attachment, required this.hiddenCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _GridCell(attachment: attachment),
        Container(
          color: AppColors.black.withValues(alpha: 0.5),
          child: Center(
            child: Text(
              '+$hiddenCount',
              style: TextStyleManager.style14Bold.copyWith(
                color: AppColors.white,
                fontSize: 22.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders an image attachment from wherever it currently lives: a device file
/// while the upload is in flight, or the disk-cached network image after it.
class _AttachmentImage extends StatelessWidget {
  final ChatMediaAttachment attachment;

  const _AttachmentImage({required this.attachment});

  @override
  Widget build(BuildContext context) {
    if (!attachment.isLocal) {
      return AppImage(attachment.url, fit: BoxFit.cover);
    }

    return Image.file(
      File(attachment.url),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.primary.withValues(alpha: 0.1),
        child: Icon(Icons.broken_image_rounded,
            color: AppColors.primary, size: 32.sp),
      ),
    );
  }
}
