import 'dart:io';

import 'package:flutter/material.dart';

import 'package:fitness_day/core/utils/attachment_opener.dart';
import 'package:fitness_day/core/widgets/full_screen_image_view.dart';
import 'package:fitness_day/core/widgets/video_viewer_dialog.dart';
import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';
import 'package:fitness_day/features/shared/conversations/presentation/models/local_chat_message.dart';

/// Opens [attachment] in the viewer that fits its type:
///   - image → [FullScreenImageView] (zoom + drag to dismiss)
///   - video → [VideoViewerDialog]
///   - anything else → the native app, falling back to the in-app WebView
///
/// Works for both a server URL and a file that is still uploading.
void openChatAttachment(
  BuildContext context,
  ChatMediaAttachment attachment, {
  List<ChatMediaAttachment>? allAttachments,
}) {
  if (attachment.isImage) {
    final list = allAttachments ?? [attachment];
    final items = list.map((a) => FullScreenImageItem(
      imageUrl: a.isLocal ? null : a.url,
      imageFile: a.isLocal ? File(a.url) : null,
      heroTag: 'chat_media_${a.id}_${a.url}',
    )).toList();
    final initialIndex = list.indexWhere((a) => a.url == attachment.url);

    FullScreenImageView.show(
      context,
      items: items,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
      heroTag: 'chat_media_${attachment.id}_${attachment.url}',
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
  List<LocalChatMessage>? allImages,
}) {
  if (isVideo) {
    VideoViewerDialog.show(context, source: path);
  } else {
    final images = allImages ?? [];
    if (images.isNotEmpty) {
      final validImages = images.where((msg) => msg.path != null).toList();
      final items = validImages.map((msg) => FullScreenImageItem(
        imageFile: File(msg.path!),
        heroTag: 'local_chat_media_${msg.path}',
      )).toList();
      final initialIndex = validImages.indexWhere((msg) => msg.path == path);

      FullScreenImageView.show(
        context,
        items: items,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
        heroTag: 'local_chat_media_$path',
      );
    } else {
      FullScreenImageView.show(
        context,
        heroTag: 'local_chat_media_$path',
        imageFile: File(path),
      );
    }
  }
}
