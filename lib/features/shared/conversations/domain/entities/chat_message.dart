/// A single media attachment inside a chat message.
///
/// Matches the API shape:
/// ```json
/// {
///   "id":       "6a66140e525c6480272941c6",
///   "url":      "https://fitnessday.tech/uploads/chat-messages-media/...",
///   "type":     "document",
///   "mimeType": "application/pdf",
///   "title":    "خطة التغذية - الأسبوع الثالث"
/// }
/// ```
class ChatMediaAttachment {
  final String id;
  final String url;

  /// Server type: "image" | "video" | "audio" | "document" ("file" on older
  /// messages).
  final String type;
  final String mimeType;

  /// Readable name of a **document**, and the only place it exists: the stored
  /// file is renamed to a UUID, so [url] carries no usable label. `null` for
  /// every other type — the server never sets it for images/video/audio.
  final String? title;

  const ChatMediaAttachment({
    required this.id,
    required this.url,
    required this.type,
    required this.mimeType,
    this.title,
  });

  /// Attachment that still lives on this device — used for the optimistic
  /// bubble shown while the upload is in flight. [url] holds the file path
  /// and the type is inferred from the extension.
  factory ChatMediaAttachment.local(String path, {String? title}) {
    final String name = path.split(RegExp(r'[/\\]')).last;
    final int dot = name.lastIndexOf('.');
    final String ext = dot == -1 ? '' : name.substring(dot + 1).toLowerCase();

    const imageExt = {'jpg', 'jpeg', 'png', 'heic', 'heif', 'webp', 'gif'};
    const videoExt = {'mp4', 'mov', 'avi', 'mkv', '3gp', 'webm'};
    const audioExt = {'m4a', 'mp3', 'aac', 'wav', 'ogg'};

    final String type = imageExt.contains(ext)
        ? 'image'
        : videoExt.contains(ext)
            ? 'video'
            : audioExt.contains(ext)
                ? 'audio'
                : 'document';

    return ChatMediaAttachment(
      id: '',
      url: path,
      type: type,
      mimeType: '',
      // So the sender's own bubble shows the same name the recipient will get.
      title: type == 'document' ? (title ?? name) : null,
    );
  }

  bool get isImage => type == 'image' || type == 'photo';
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio';

  /// `file` is what older messages carry; the server sends `document` now.
  bool get isDocument => type == 'document' || type == 'file';

  /// What the document row shows. [title] first — falling back to the URL's
  /// last segment only for legacy messages stored before titles existed, where
  /// it is the UUID the file was renamed to.
  String get displayName {
    final String? name = title?.trim();
    if (name != null && name.isNotEmpty) return name;
    final Uri? uri = Uri.tryParse(url);
    final String fromUrl = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last
        : url.split(RegExp(r'[/\\]')).last;
    return Uri.decodeComponent(fromUrl);
  }

  /// True while [url] still points at a device file path instead of a
  /// server URL — the UI renders those with `Image.file` / a local player.
  bool get isLocal => !url.startsWith('http');
}

/// Domain entity — pure Dart, no Flutter or data-layer imports.
///
/// Fields map 1-to-1 with the API response under
/// `GET /chat/:id/messages → data.messages[]`.
class ChatMessage {
  final String id;
  final String conversationId;

  /// The text body of the message. Empty string when the message is media-only.
  final String text;

  /// Who sent it: "user" | "specialist" — as returned by the API.
  final String senderType;

  /// True when this message was sent by the currently logged-in user.
  final bool isMine;

  /// Delivery status.
  final MessageStatus status;

  final DateTime createdAt;

  /// List of media attachments (images, videos, etc.).
  /// Populated when the server returns a `media` array.
  final List<ChatMediaAttachment> media;

  // ── Convenience getters ──────────────────────────────────────────────────

  bool get isMedia => media.isNotEmpty;
  bool get hasImages => media.any((m) => m.isImage);
  bool get hasVideo => media.any((m) => m.isVideo);

  /// Shortcut for single-media messages (backward compat).
  String? get mediaUrl => media.isNotEmpty ? media.first.url : null;
  String? get mediaType => media.isNotEmpty ? media.first.type : null;
  bool get isPhoto => hasImages;
  bool get isVideo => hasVideo;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.senderType,
    required this.isMine,
    required this.status,
    required this.createdAt,
    this.media = const [],
  });

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? text,
    String? senderType,
    bool? isMine,
    MessageStatus? status,
    DateTime? createdAt,
    List<ChatMediaAttachment>? media,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      text: text ?? this.text,
      senderType: senderType ?? this.senderType,
      isMine: isMine ?? this.isMine,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      media: media ?? this.media,
    );
  }
}

/// Strongly-typed delivery status enum.
enum MessageStatus {
  sent,       // emitted via socket, not yet acked
  delivered,  // received by other party's device
  seen,       // other party opened / read it
  unknown,    // clock icon — optimistic before server ack
}
