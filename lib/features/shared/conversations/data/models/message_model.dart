import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';

/// Data-layer model for a single media attachment.
class ChatMediaAttachmentModel extends ChatMediaAttachment {
  const ChatMediaAttachmentModel({
    required super.id,
    required super.url,
    required super.type,
    required super.mimeType,
    super.title,
  });

  factory ChatMediaAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ChatMediaAttachmentModel(
      id: (json['id'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'file',
      mimeType: (json['mimeType'] as String?) ?? '',
      // The document's readable name. Comes through both the REST response and
      // the `chat:message` socket event, so the recipient gets it too — the
      // URL is a UUID and carries nothing usable.
      title: json['title'] as String?,
    );
  }
}

/// Data-layer model that knows how to parse the API JSON response.
///
/// API shape (from `GET /chat/:id/messages` AND `chat:message` socket event):
/// ```json
/// {
///   "id":             "6a66140e...",
///   "conversationId": "6a65f3eb...",
///   "text":           null,
///   "media": [
///     { "id": "...", "url": "https://...", "type": "image", "mimeType": "image/png" }
///   ],
///   "senderType":  "user",
///   "isMine":      true,
///   "status":      "sent",
///   "createdAt":   "2026-07-26T14:05:02.623Z"
/// }
/// ```
class MessageModel extends ChatMessage {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.text,
    required super.senderType,
    required super.isMine,
    required super.status,
    required super.createdAt,
    super.media = const [],
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Parse media array (new API format).
    final rawMedia = json['media'];
    final List<ChatMediaAttachment> mediaList;
    if (rawMedia is List && rawMedia.isNotEmpty) {
      mediaList = rawMedia
          .whereType<Map>()
          .map((m) => ChatMediaAttachmentModel.fromJson(
              Map<String, dynamic>.from(m)))
          .toList();
    } else {
      // Legacy fallback: single mediaUrl / mediaType fields.
      final url = json['mediaUrl'] as String?;
      final type = json['mediaType'] as String?;
      if (url != null && url.isNotEmpty) {
        mediaList = [
          ChatMediaAttachmentModel(
            id: '',
            url: url,
            type: type ?? 'file',
            mimeType: '',
          )
        ];
      } else {
        mediaList = const [];
      }
    }

    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      text: (json['text'] as String?) ?? '',
      senderType: (json['senderType'] as String?) ?? 'user',
      isMine: json['isMine'] as bool? ?? false,
      status: _parseStatus(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      media: mediaList,
    );
  }

  static MessageStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'seen':
        return MessageStatus.seen;
      default:
        return MessageStatus.unknown;
    }
  }
}
