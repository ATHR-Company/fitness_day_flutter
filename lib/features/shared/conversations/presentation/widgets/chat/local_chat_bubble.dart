import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/conversations/presentation/models/local_chat_message.dart';
import 'package:fitness_day/features/shared/conversations/presentation/utils/chat_attachment_viewer.dart';
import 'package:fitness_day/features/shared/conversations/presentation/utils/chat_time_format.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_audio_bubble.dart';

/// Bubble for an in-memory [LocalChatMessage] — the AI and user-to-user
/// screens, which render picked media straight from its device path.
class LocalChatBubble extends StatelessWidget {
  final LocalChatMessage message;

  /// Opens the reaction picker; the parent owns the resulting emoji.
  final VoidCallback onLongPress;

  const LocalChatBubble({
    super.key,
    required this.message,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isMe;

    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: onLongPress,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 0.72.sw),
                  padding: message.kind == LocalMessageKind.text
                      ? EdgeInsets.all(16.w)
                      : EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.white
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r).copyWith(
                      topLeft: Radius.circular(isMe ? 0 : 16.r),
                      topRight: Radius.circular(isMe ? 16.r : 0),
                    ),
                    boxShadow: [
                      if (isMe)
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: _LocalBubbleContent(message: message),
                ),
                if (message.reaction != null)
                  PositionedDirectional(
                    bottom: -10.h,
                    end: 8.w,
                    child: _ReactionChip(emoji: message.reaction!),
                  ),
              ],
            ),
          ),
          SizedBox(height: message.reaction != null ? 14.h : 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMe) ...[
                Icon(Icons.done_all, color: AppColors.primary, size: 14.sp),
                SizedBox(width: 4.w),
              ],
              Text(
                formatChatTime(message.time),
                style: TextStyleManager.heading3.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocalBubbleContent extends StatelessWidget {
  final LocalChatMessage message;

  const _LocalBubbleContent({required this.message});

  @override
  Widget build(BuildContext context) {
    switch (message.kind) {
      case LocalMessageKind.text:
        return Text(
          message.text ?? '',
          style: TextStyleManager.style11Medium,
        );

      case LocalMessageKind.image:
        return GestureDetector(
          onTap: () => openLocalChatMedia(
            context,
            path: message.path!,
            isVideo: false,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              File(message.path!),
              width: 200.w,
              height: 200.w,
              fit: BoxFit.cover,
            ),
          ),
        );

      case LocalMessageKind.video:
        return GestureDetector(
          onTap: () => openLocalChatMedia(
            context,
            path: message.path!,
            isVideo: true,
          ),
          child: Container(
            width: 200.w,
            height: 150.w,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow_rounded,
                    color: AppColors.primary, size: 30.sp),
              ),
            ),
          ),
        );

      case LocalMessageKind.audio:
        return ChatAudioBubble(source: message.path!);

      case LocalMessageKind.file:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file_rounded,
                  color: AppColors.primary, size: 28.sp),
              SizedBox(width: 10.w),
              Flexible(
                child: Text(
                  message.fileName ?? 'conversations.attach_document'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleManager.style11Medium
                      .copyWith(color: AppColors.black),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _ReactionChip extends StatelessWidget {
  final String emoji;

  const _ReactionChip({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        emoji,
        style: TextStyleManager.style11Medium.copyWith(fontSize: 13.sp),
      ),
    );
  }
}
