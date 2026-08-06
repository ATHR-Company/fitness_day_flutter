import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';
import 'package:fitness_day/features/shared/conversations/presentation/utils/chat_time_format.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_expandable_text.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_media_grid.dart';

/// WhatsApp-style bubble for a server-backed [ChatMessage].
///
/// Renders media (single or grid), the text body, and a metadata row with the
/// timestamp and — for outgoing messages — the delivery ticks.
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final List<ChatMediaAttachment>? allChatImages;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.allChatImages,
  });

  /// An outgoing message that has neither text nor media yet is an optimistic
  /// placeholder: the upload is still in flight.
  bool get _isUploadingMedia =>
      !message.isMedia &&
      message.text.isEmpty &&
      message.status == MessageStatus.unknown;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final bool hasText = message.text.isNotEmpty;
    final bool hasMedia = message.isMedia;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.76.sw),
        margin: EdgeInsets.symmetric(vertical: 2.h),
        padding: hasMedia
            ? EdgeInsets.all(4.w)
            : EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 6.h),
        decoration: BoxDecoration(
          color: message.isMine
              ? AppColors.white
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft: Radius.circular(message.isMine ? 14.r : 2.r),
            bottomRight: Radius.circular(message.isMine ? 2.r : 14.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.07),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isUploadingMedia) const _UploadPlaceholder(),

            if (hasMedia)
              ChatMediaGrid(
                attachments: message.media,
                isMine: message.isMine,
                allChatImages: allChatImages,
              ),

            if (hasText)
              Padding(
                padding: hasMedia
                    ? EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 2.h)
                    : EdgeInsets.zero,
                child: ChatExpandableText(
                  text: message.text,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: TextStyleManager.style11Medium.copyWith(
                    fontSize: 13.sp,
                    height: 1.35,
                  ),
                ),
              ),

            if (!hasMedia) SizedBox(height: 3.h),

            // Metadata sits on the bubble background rather than on top of the
            // media, so the tick stays readable on every message type.
            Padding(
              padding: hasMedia
                  ? EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 2.h)
                  : EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    formatChatTime(message.createdAt),
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 9.sp,
                    ),
                  ),
                  if (message.isMine) ...[
                    SizedBox(width: 4.w),
                    MessageStatusIcon(status: message.status),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Delivery ticks: clock while pending, one tick when sent, double ticks once
/// delivered — turning blue when the other party has read the message.
class MessageStatusIcon extends StatelessWidget {
  static const Color _seenColor = Color(0xFF34B7F1);

  final MessageStatus status;

  const MessageStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color pendingColor = AppColors.textSecondary.withValues(alpha: 0.8);

    switch (status) {
      case MessageStatus.sent:
        return Icon(Icons.check, color: pendingColor, size: 13.sp);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, color: pendingColor, size: 14.sp);
      case MessageStatus.seen:
        return Icon(Icons.done_all, color: _seenColor, size: 14.sp);
      case MessageStatus.unknown:
        return Icon(Icons.access_time_rounded,
            color: pendingColor, size: 11.sp);
    }
  }
}

/// Grey box with a spinner, shown in place of the media while it uploads.
class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      height: 140.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
