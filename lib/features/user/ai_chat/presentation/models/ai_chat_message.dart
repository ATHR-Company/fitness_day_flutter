/// One bubble in the AI coach conversation.
///
/// The conversation is in-memory only — nothing is persisted between visits.
class AiChatMessage {
  final String content;
  final bool isMe;
  final DateTime time;

  const AiChatMessage({
    required this.content,
    required this.isMe,
    required this.time,
  });
}
