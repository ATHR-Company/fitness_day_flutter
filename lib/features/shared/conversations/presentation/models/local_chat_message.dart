/// Kinds of message a local bubble can render.
enum LocalMessageKind { text, image, video, audio, file }

/// A message that only ever lives in memory.
///
/// Used by the AI and user-to-user screens, which have no backend yet — picked
/// media and recordings are rendered straight from their on-device file path.
/// Server-backed chats use the `ChatMessage` domain entity instead.
class LocalChatMessage {
  final LocalMessageKind kind;

  /// Body of a text message.
  final String? text;

  /// Device file path for an image / video / audio / document message.
  final String? path;

  /// Display name of a document.
  final String? fileName;

  final bool isMe;
  final DateTime time;

  /// Emoji attached by long-pressing the bubble. Mutable and in-memory only —
  /// there is no backend, so it is never persisted.
  String? reaction;

  LocalChatMessage({
    required this.kind,
    required this.isMe,
    required this.time,
    this.text,
    this.path,
    this.fileName,
  });
}
