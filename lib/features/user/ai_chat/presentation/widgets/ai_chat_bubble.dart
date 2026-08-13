import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/conversations/presentation/utils/chat_time_format.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_expandable_text.dart';
import 'package:fitness_day/features/user/ai_chat/presentation/models/ai_chat_message.dart';
import 'package:fitness_day/core/widgets/typing_dots_indicator.dart';

/// A single AI-coach bubble, with the timestamp underneath.
class AiChatBubble extends StatelessWidget {
  final AiChatMessage message;

  const AiChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isMe;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 0.75.sw),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.white
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
                    bottomRight: Radius.circular(isMe ? 4.r : 16.r),
                  ),
                  border: isMe
                      ? Border.all(color: AppColors.divider, width: 0.5)
                      : null,
                ),
                // The coach answers at length, and an unclamped reply pushed
                // the question that prompted it off screen. Same collapse the
                // normal chat uses, so both read identically.
                child: ChatExpandableText(
                  text: message.content,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.black,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatChatTime(message.time),
                    style: TextStyleManager.style10Medium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 4.w),
                    Icon(Icons.done_all,
                        size: 14.sp, color: AppColors.primary),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown while the coach is composing an answer.
class AiChatTypingBubble extends StatelessWidget {
  const AiChatTypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: TypingDotsIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}
