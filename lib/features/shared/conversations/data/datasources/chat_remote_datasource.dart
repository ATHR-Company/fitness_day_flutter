import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  Future<List<UserConversation>> getSpecialistChats();
  Future<String> openSpecialistChat(String userId);
  Future<ChatMessagesPage> getSpecialistMessages(String conversationId, {int page = 1});
  Future<MessageModel> sendSpecialistMedia({
    required String conversationId,
    required List<XFile> files,
  });
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
  Future<List<UserConversation>> getSpecialistChats() async {
    debugPrint('[REST] GET ${ApiEndpoints.specialistChats}');
    final response = await _api.get(ApiEndpoints.specialistChats);
    final List<dynamic> rawList =
        response.data['data'] as List<dynamic>? ?? [];
    debugPrint('[REST] getSpecialistChats → ${rawList.length} conversations');
    return rawList
        .map((item) =>
            UserConversation.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
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
      final multipart = await MultipartFile.fromFile(
        f.path,
        filename: f.name,
      );
      formData.files.add(MapEntry('chat-media', multipart));
    }

    final response = await _api.post(endpoint, data: formData);
    final msgJson = Map<String, dynamic>.from(response.data['data'] as Map);
    final model = MessageModel.fromJson(msgJson);
    debugPrint(
        '[REST] uploadMedia → msgId=${model.id}, media count=${model.media.length}');
    return model;
  }
}
