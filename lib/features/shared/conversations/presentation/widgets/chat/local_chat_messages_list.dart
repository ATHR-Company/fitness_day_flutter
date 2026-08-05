import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/conversations/presentation/models/local_chat_message.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/chat/local_chat_bubble.dart';

/// Scrollable list of in-memory messages, used by the chats that have no
/// backend yet. Unlike [ChatMessagesList] it is not reversed — there is no
/// pagination, so the newest message is simply the last item.
class LocalChatMessagesList extends StatelessWidget {
  final List<LocalChatMessage> messages;
  final ScrollController controller;

  /// Called when a bubble is long-pressed, to open the reaction picker.
  final ValueChanged<LocalChatMessage> onReact;

  const LocalChatMessagesList({
    super.key,
    required this.messages,
    required this.controller,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    final allLocalImages = messages
        .where((m) => m.kind == LocalMessageKind.image)
        .toList();

    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Center(
              child: Text(
                'conversations.today'.tr(),
                style: TextStyleManager.style11Medium,
              ),
            ),
          );
        }

        final message = messages[index - 1];
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: LocalChatBubble(
            message: message,
            onLongPress: () => onReact(message),
            allLocalImages: allLocalImages,
          ),
        );
      },
    );
  }
}
