/// Other party in a user conversation (e.g. Specialist)
class ConversationOtherParty {
  final String id;
  final String name;
  final String? avatar;
  final bool online;

  const ConversationOtherParty({
    required this.id,
    required this.name,
    this.avatar,
    this.online = false,
  });

  factory ConversationOtherParty.fromJson(Map<String, dynamic> json) {
    return ConversationOtherParty(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      online: json['online'] as bool? ?? false,
    );
  }
}

/// User active conversation object returned by `GET /chat`
///
/// Handles both server response shapes seamlessly:
///
/// Shape 1 (conversation exists):
/// ```json
/// {
///   "conversationId": "6a65f3eb1a3c1f7737798fb1",
///   "conversation": {
///     "id": "6a65f3eb1a3c1f7737798fb1",
///     "otherParty": { ... },
///     "lastMessage": null,
///     "unreadCount": 0
///   }
/// }
/// ```
///
/// Shape 2 (no conversation yet, but specialist assigned):
/// ```json
/// {
///   "conversationId": null,
///   "otherParty": { ... },
///   "lastMessage": null,
///   "unreadCount": 0
/// }
/// ```
class UserConversation {
  final String? conversationId;
  final ConversationOtherParty? otherParty;
  final String? lastMessageText;
  final String? lastMessageMediaType;
  final int unreadCount;

  const UserConversation({
    this.conversationId,
    this.otherParty,
    this.lastMessageText,
    this.lastMessageMediaType,
    this.unreadCount = 0,
  });

  /// Formatted last message representation (e.g. text or media label)
  String? get displayLastMessage {
    if (lastMessageText != null && lastMessageText!.isNotEmpty) {
      return lastMessageText;
    }
    if (lastMessageMediaType != null) {
      switch (lastMessageMediaType) {
        case 'photo':
        case 'image':
          return '📷 صورة';
        case 'video':
          return '🎥 فيديو';
        case 'audio':
        case 'voice':
          return '🎤 رسالة صوتية';
        case 'file':
        case 'document':
          return '📄 مستند';
        default:
          return 'مرفق';
      }
    }
    return null;
  }

  factory UserConversation.fromJson(Map<String, dynamic> json) {
    // If "conversation" object exists, fallback/read from inside it
    final convObj = json['conversation'] as Map<String, dynamic>?;

    // Check conversationId: root conversationId, root id, or inside conversation object
    final id = json['conversationId'] as String? ??
        json['id'] as String? ??
        convObj?['id'] as String?;

    // Check otherParty: root or inside conversation object
    final otherPartyMap = (json['otherParty'] as Map<String, dynamic>?) ??
        (convObj?['otherParty'] as Map<String, dynamic>?);

    // Check lastMessage: root or inside conversation object
    final lastMsgMap = (json['lastMessage'] as Map<String, dynamic>?) ??
        (convObj?['lastMessage'] as Map<String, dynamic>?);

    // Check unreadCount: root or inside conversation object
    final unread = (json['unreadCount'] as int?) ??
        (convObj?['unreadCount'] as int?) ??
        0;

    return UserConversation(
      conversationId: id,
      otherParty: otherPartyMap != null
          ? ConversationOtherParty.fromJson(otherPartyMap)
          : null,
      lastMessageText: lastMsgMap?['text'] as String?,
      lastMessageMediaType: lastMsgMap?['mediaType'] as String?,
      unreadCount: unread,
    );
  }
}
