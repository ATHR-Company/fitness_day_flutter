import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/chat_cubit.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/chat_state.dart';

/// Chat header — back button, avatar with online dot, name and typing hint.
///
/// The name and avatar handed over by the caller win, so the header is already
/// correct on the first frame; the values that arrive with the messages
/// response fill in for screens that open a conversation directly.
class ChatHeader extends StatelessWidget {
  final String? title;
  final String? avatarUrl;
  final bool isAi;
  final bool isSpecialist;

  /// Tapping the avatar or the name runs this. Null leaves the header inert —
  /// there is nowhere to go from an AI chat, or from a chat whose other party
  /// has no profile page on this side of the app.
  final VoidCallback? onProfileTap;

  const ChatHeader({
    super.key,
    this.title,
    this.avatarUrl,
    this.isAi = false,
    this.isSpecialist = false,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: const BoxDecoration(color: AppColors.backgroundTint),
      child: Column(
        children: [
          SizedBox(height: 30.h),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              final ChatLoaded? loaded = state is ChatLoaded ? state : null;
              final other = loaded?.otherParty;

              // Falls back to a neutral label, never to a made-up name: the
              // gap here is "the conversation hasn't loaded yet", and showing
              // a placeholder person reads as the real correspondent.
              final String name = (title?.isNotEmpty ?? false)
                  ? title!
                  : ((other?.name.isNotEmpty ?? false)
                      ? other!.name
                      : 'conversations.title'.tr());
              final String? avatar = (avatarUrl?.isNotEmpty ?? false)
                  ? avatarUrl
                  : other?.avatar;

              return Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios,
                        color: AppColors.black, size: 20.sp),
                  ),
                  // Avatar and name are one target, so the whole identity block
                  // behaves like the single link it looks like.
                  Expanded(
                    child: GestureDetector(
                      onTap: onProfileTap,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          _Avatar(
                            avatar: avatar,
                            isAi: isAi,
                            isSpecialist: isSpecialist,
                            isOnline: isAi || (other?.online ?? false),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _NameAndStatus(
                              name: name,
                              isTyping: loaded?.isOtherPartyTyping ?? false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatar;
  final bool isAi;
  final bool isSpecialist;
  final bool isOnline;

  const _Avatar({
    required this.avatar,
    required this.isAi,
    required this.isSpecialist,
    required this.isOnline,
  });

  /// Network pictures go through [AppImage], which renders them with a
  /// disk-cached provider — re-entering the chat reuses the cached file
  /// instead of downloading it again.
  Widget _buildPicture() {
    if (isAi) return AppImage(AppImages.ai, fit: BoxFit.cover);
    if (avatar != null && avatar!.isNotEmpty) {
      return AppImage(
        avatar,
        width: 50.r,
        height: 50.r,
        fit: BoxFit.cover,
        isAvatar: true,
      );
    }
    if (isSpecialist) return AppImage(SvgIcons.logo, fit: BoxFit.cover);
    return Icon(Icons.person, color: AppColors.primary, size: 24.sp);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPicture = avatar != null && avatar!.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 50.r,
          height: 50.r,
          padding: hasPicture ? EdgeInsets.zero : EdgeInsets.all(8.r),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildPicture(),
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.backgroundTint, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _NameAndStatus extends StatelessWidget {
  final String name;
  final bool isTyping;

  const _NameAndStatus({required this.name, required this.isTyping});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyleManager.style14Bold.copyWith(color: AppColors.black),
        ),
        if (isTyping) ...[
          SizedBox(height: 2.h),
          Text(
            'conversations.typing'.tr(),
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.primary,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
