import 'dart:io';

import 'package:flutter/material.dart';

import 'package:fitness_day/core/utils/attachment_opener.dart';
import 'package:fitness_day/core/widgets/full_screen_image_view.dart';
import 'package:fitness_day/core/widgets/video_viewer_dialog.dart';
import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';

/// Opens [attachment] in the viewer that fits its type:
///   - image → [FullScreenImageView] (zoom + drag to dismiss)
///   - video → [VideoViewerDialog]
///   - anything else → the native app, falling back to the in-app WebView
///
/// Works for both a server URL and a file that is still uploading.
void openChatAttachment(BuildContext context, ChatMediaAttachment attachment) {
  if (attachment.isImage) {
    FullScreenImageView.show(
      context,
      heroTag: 'chat_media_${attachment.id}_${attachment.url}',
      imageUrl: attachment.isLocal ? null : attachment.url,
      imageFile: attachment.isLocal ? File(attachment.url) : null,
    );
    return;
  }

  if (attachment.isVideo) {
    VideoViewerDialog.show(
      context,
      source: attachment.url,
      isNetwork: !attachment.isLocal,
    );
    return;
  }

  AttachmentOpener.open(context, url: attachment.url);
}

/// Opens a local file path picked on this device (used by the in-memory
/// chats, which have no [ChatMediaAttachment] to describe the file).
void openLocalChatMedia(
  BuildContext context, {
  required String path,
  required bool isVideo,
}) {
  if (isVideo) {
    VideoViewerDialog.show(context, source: path);
  } else {
    FullScreenImageView.show(
      context,
      heroTag: 'local_chat_media_$path',
      imageFile: File(path),
    );
  }
}
