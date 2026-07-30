import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/chat_state.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_message_bubble.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/chat_typing_bubble.dart';

/// Scrollable list of server-backed messages.
///
/// The list is reversed, so index 0 is the *newest* message and sits at the
/// bottom of the screen. Older pages are appended at the far end, which means
/// loading one can never shift what the user is currently looking at — no
/// offset-restore maths, no jumping.
class ChatMessagesList extends StatelessWidget {
  final ChatLoaded state;
  final ScrollController controller;

  const ChatMessagesList({
    super.key,
    required this.state,
    required this.controller,
  });

  /// Typing bubble sits at index 0 — visually right under the newest message.
  int get _headCount => state.isOtherPartyTyping ? 1 : 0;

  /// The far end of the list carries the "loading older messages" spinner, or
  /// the "Today" label once the whole history is in.
  int get _tailCount => state.isLoadingMore || !state.hasMore ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    final messages = state.messages;

    return ListView.builder(
      controller: controller,
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      itemCount: messages.length + _headCount + _tailCount,
      itemBuilder: (context, rawIndex) {
        if (_headCount == 1 && rawIndex == 0) {
          return const _ListSlot(child: ChatTypingBubble());
        }

        final int index = rawIndex - _headCount;
        if (index < messages.length) {
          return _ListSlot(
            child: ChatMessageBubble(
              message: messages[messages.length - 1 - index],
            ),
          );
        }

        return _ListSlot(
          child: state.isLoadingMore
              ? const _LoadingMoreIndicator()
              : const _TodayLabel(),
        );
      },
    );
  }
}

/// Uniform spacing between the items of a reversed list.
class _ListSlot extends StatelessWidget {
  final Widget child;

  const _ListSlot({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(top: 16.h), child: child);
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 22.w,
        height: 22.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _TodayLabel extends StatelessWidget {
  const _TodayLabel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'conversations.today'.tr(),
        style: TextStyleManager.style11Medium,
      ),
    );
  }
}
