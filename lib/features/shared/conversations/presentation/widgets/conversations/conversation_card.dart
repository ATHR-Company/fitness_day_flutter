import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';

/// One row in the conversations list: avatar with online dot, name, the last
/// message and either the unread badge or a chevron.
class ConversationCard extends StatelessWidget {
  final UserConversation conversation;
  final VoidCallback onTap;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  /// Preview line: the last message, or why there isn't one yet.
  String get _preview {
    if (conversation.conversationId == null) {
      return 'conversations.no_conversation'.tr();
    }
    final String last = conversation.displayLastMessage ?? '';
    return last.isNotEmpty ? last : 'conversations.no_messages'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final otherParty = conversation.otherParty;
    final String name = otherParty?.name ?? '';
    final int unreadCount = conversation.unreadCount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _ConversationAvatar(
              avatar: otherParty?.avatar,
              isOnline: otherParty?.online ?? false,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name.isNotEmpty
                        ? name
                        : 'conversations.unknown_client'.tr(),
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    _preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            if (unreadCount > 0)
              _UnreadBadge(count: unreadCount)
            else
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: 14.sp,
              ),
          ],
        ),
      ),
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  final String? avatar;
  final bool isOnline;

  const _ConversationAvatar({required this.avatar, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final bool hasPicture = avatar != null && avatar!.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 50.r,
          height: 50.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasPicture
              ? AppImage(avatar, fit: BoxFit.cover, isAvatar: true)
              : Icon(
                  Icons.person,
                  size: 28.sp,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 2.w,
            child: Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        '$count',
        style: TextStyleManager.heading3.copyWith(
          color: AppColors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
