import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:image_picker/image_picker.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/features/shared/conversations/data/models/message_model.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';

/// Responsible for all HTTP calls related to chat (both User and Specialist).
abstract class ChatRemoteDataSource {
  // User Chat
  Future<String> openChat(String specialistId);
  Future<ChatMessagesPage> getMessages(String conversationId, {int page = 1});
  Future<UserConversation?> getUserChat();
  Future<MessageModel> sendMedia({
    required String conversationId,
    required List<XFile> files,
  });

  // Specialist Chat
  Future<ConversationsPageResult> getSpecialistChats({int page, int limit});
  Future<String> openSpecialistChat(String userId);
  Future<ChatMessagesPage> getSpecialistMessages(String conversationId, {int page = 1});
  Future<MessageModel> sendSpecialistMedia({
    required String conversationId,
    required List<XFile> files,
  });
}

/// One page of the specialist's conversation list.
class ConversationsPageResult {
  final List<UserConversation> conversations;
  final int page;
  final int totalPages;
  final int totalCount;

  const ConversationsPageResult({
    required this.conversations,
    required this.page,
    required this.totalPages,
    required this.totalCount,
  });

  bool get hasMore => page < totalPages;
}

/// Holds the paginated result from a messages endpoint.
class ChatMessagesPage {
  final List<MessageModel> messages;
  final int page;
  final int totalPages;

  /// `data.conversation.otherParty` — name/avatar/online of the person on the
  /// other side, used for the chat header.
  final ConversationOtherParty? otherParty;

  const ChatMessagesPage({
    required this.messages,
    required this.page,
    required this.totalPages,
    this.otherParty,
  });
}

/// Reads `data.conversation.otherParty` from a messages response, when present.
ConversationOtherParty? _parseOtherParty(dynamic data) {
  if (data is! Map) return null;
  final conversation = data['conversation'];
  if (conversation is! Map) return null;
  final raw = conversation['otherParty'];
  if (raw is! Map) return null;
  return ConversationOtherParty.fromJson(Map<String, dynamic>.from(raw));
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiService _api;

  const ChatRemoteDataSourceImpl(this._api);

  // ── User Chat Implementation ─────────────────────────────────────────────

  @override
  Future<String> openChat(String specialistId) async {
    debugPrint('[REST] POST ${ApiEndpoints.openChat} specialistId=$specialistId');
    final response = await _api.post(
      ApiEndpoints.openChat,
      data: {'specialistId': specialistId},
    );
    final id = (response.data['data']['conversationId'] ??
        response.data['data']['id']) as String;
    debugPrint('[REST] openChat → conversationId=$id');
    return id;
  }

  @override
  Future<ChatMessagesPage> getMessages(String conversationId, {int page = 1}) async {
    debugPrint('[REST] GET ${ApiEndpoints.getChatMessages(conversationId)} page=$page');
    final response = await _api.get(
      ApiEndpoints.getChatMessages(conversationId),
      queryParameters: {'page': page},
    );
    final List<dynamic> rawList =
        response.data['data']['messages'] as List<dynamic>;
    final int totalPages = (response.data['totalPages'] as num?)?.toInt() ?? 1;
    debugPrint('[REST] getMessages → ${rawList.length} messages  totalPages=$totalPages');
    return ChatMessagesPage(
      messages: rawList
          .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: page,
      totalPages: totalPages,
      otherParty: _parseOtherParty(response.data['data']),
    );
  }

  @override
  Future<UserConversation?> getUserChat() async {
    debugPrint('[REST] GET ${ApiEndpoints.getChats}');
    final response = await _api.get(ApiEndpoints.getChats);
    final data = response.data['data'];
    if (data == null || (data is Map && data.isEmpty)) return null;
    return UserConversation.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<MessageModel> sendMedia({
    required String conversationId,
    required List<XFile> files,
  }) async {
    final endpoint = ApiEndpoints.sendChatMedia(conversationId);
    return _uploadMediaFiles(endpoint, files);
  }

  // ── Specialist Chat Implementation ──────────────────────────────────────

  @override
  Future<ConversationsPageResult> getSpecialistChats({
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint('[REST] GET ${ApiEndpoints.specialistChats}  page=$page');
    final response = await _api.get(
      ApiEndpoints.specialistChats,
      queryParameters: {'page': page, 'limit': limit},
    );
    final List<dynamic> rawList =
        response.data['data'] as List<dynamic>? ?? [];
    // `totalCount` / `page` / `totalPages` sit next to `data`, not inside it.
    final int currentPage = (response.data['page'] as num?)?.toInt() ?? page;
    final int totalPages = (response.data['totalPages'] as num?)?.toInt() ?? 1;
    debugPrint(
        '[REST] getSpecialistChats → ${rawList.length} conversations  page=$currentPage/$totalPages');
    return ConversationsPageResult(
      conversations: rawList
          .map((item) =>
              UserConversation.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      page: currentPage,
      totalPages: totalPages,
      totalCount: (response.data['totalCount'] as num?)?.toInt() ?? rawList.length,
    );
  }

  @override
  Future<String> openSpecialistChat(String userId) async {
    final endpoint = ApiEndpoints.openSpecialistChat(userId);
    debugPrint('[REST] POST $endpoint');
    final response = await _api.post(endpoint);
    final data = response.data['data'];
    final id = (data['conversationId'] ?? data['id']) as String;
    debugPrint('[REST] openSpecialistChat → conversationId=$id');
    return id;
  }

  @override
  Future<ChatMessagesPage> getSpecialistMessages(String conversationId, {int page = 1}) async {
    final endpoint = ApiEndpoints.getSpecialistChatMessages(conversationId);
    debugPrint('[REST] GET $endpoint page=$page');
    final response = await _api.get(
      endpoint,
      queryParameters: {'page': page},
    );
    final List<dynamic> rawList =
        response.data['data']['messages'] as List<dynamic>;
    final int totalPages = (response.data['totalPages'] as num?)?.toInt() ?? 1;
    debugPrint('[REST] getSpecialistMessages → ${rawList.length} messages  totalPages=$totalPages');
    return ChatMessagesPage(
      messages: rawList
          .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: page,
      totalPages: totalPages,
      otherParty: _parseOtherParty(response.data['data']),
    );
  }

  @override
  Future<MessageModel> sendSpecialistMedia({
    required String conversationId,
    required List<XFile> files,
  }) async {
    final endpoint = ApiEndpoints.sendSpecialistChatMedia(conversationId);
    return _uploadMediaFiles(endpoint, files);
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  Future<MessageModel> _uploadMediaFiles(
      String endpoint, List<XFile> files) async {
    debugPrint('[REST] POST $endpoint — uploading ${files.length} file(s)');

    final formData = FormData();
    for (final f in files) {
      final MediaType? contentType = _contentTypeFor(f.name);
      final multipart = await MultipartFile.fromFile(
        f.path,
        filename: f.name,
        // Explicit on purpose: the picker often reports a PDF as
        // `application/octet-stream` on Android, and the upload filter drops
        // an unrecognised type before the server's own code runs — the reply
        // is a bare `LIMIT_UNEXPECTED_FILE` that says nothing about the MIME.
        contentType: contentType,
      );
      formData.files.add(MapEntry('chat-media', multipart));

      // The stored file is renamed to a UUID, so this is the only thing that
      // gives the document a readable name on the recipient's side. Titles are
      // matched to files **by position**, and it is all-or-nothing across the
      // batch — hence an empty placeholder for non-documents rather than
      // skipping the entry, which would shift every later title onto the
      // wrong file.
      final bool isDocument = contentType?.subtype == 'pdf';
      formData.fields.add(MapEntry('titles', isDocument ? f.name : ''));
    }

    final response = await _api.post(endpoint, data: formData);
    final msgJson = Map<String, dynamic>.from(response.data['data'] as Map);
    final model = MessageModel.fromJson(msgJson);
    debugPrint(
        '[REST] uploadMedia → msgId=${model.id}, media count=${model.media.length}');
    return model;
  }

  /// MIME type for [fileName], derived from its extension.
  ///
  /// Only the types the server accepts are listed; anything else returns null
  /// and lets Dio decide, so an unsupported file fails on the server's own
  /// validation with a message we can show, rather than being mislabelled here.
  static MediaType? _contentTypeFor(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    if (dot == -1) return null;
    final String ext = fileName.substring(dot + 1).toLowerCase();

    return _mediaTypeByExtension[ext];
  }

  /// MediaType has no const constructor, so this is built once and reused.
  static final Map<String, MediaType> _mediaTypeByExtension = {
    // Documents — pdf is the only accepted one.
    'pdf': MediaType('application', 'pdf'),
    // Images
    'jpg': MediaType('image', 'jpeg'),
    'jpeg': MediaType('image', 'jpeg'),
    'png': MediaType('image', 'png'),
    'gif': MediaType('image', 'gif'),
    'webp': MediaType('image', 'webp'),
    // Video
    'mp4': MediaType('video', 'mp4'),
    'mov': MediaType('video', 'quicktime'),
    'avi': MediaType('video', 'x-msvideo'),
    'webm': MediaType('video', 'webm'),
    // Audio
    'mp3': MediaType('audio', 'mpeg'),
    'm4a': MediaType('audio', 'mp4'),
    'wav': MediaType('audio', 'wav'),
    'ogg': MediaType('audio', 'ogg'),
  };
}
