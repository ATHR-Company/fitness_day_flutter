import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/chat_details_page.dart';

/// Opens the chat with a client from anywhere on the specialist side.
///
/// [conversationId] is `null` for a client who has never chatted — that is not
/// an error and not a reason to hide the button: the chat screen falls back to
/// [clientId] and the backend opens the conversation on the spot. Only a
/// missing [clientId] leaves nothing to open with.
Future<void> openClientChat(
  BuildContext context, {
  required String? clientId,
  String? conversationId,
  String? clientName,
  String? avatarUrl,
}) {
  final bool hasConversation =
      conversationId != null && conversationId.isNotEmpty;
  final bool hasClient = clientId != null && clientId.isNotEmpty;
  if (!hasConversation && !hasClient) return Future<void>.value();

  final String title = (clientName != null && clientName.trim().isNotEmpty)
      ? clientName
      : 'conversations.title'.tr();

  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatDetailsPage(
        title: title,
        // Server-backed mode: without this the screen falls back to the
        // in-memory demo bubbles.
        isSpecialist: true,
        isSpecialistMode: true,
        conversationId: hasConversation ? conversationId : null,
        // In specialist mode this parameter carries the *client's* id, which
        // is what `POST /specialist/chat/:userId/open` needs.
        specialistId: clientId,
        avatarUrl: avatarUrl,
      ),
    ),
  );
}
