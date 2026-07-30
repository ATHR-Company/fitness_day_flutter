import 'package:image_picker/image_picker.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/data/datasources/chat_remote_datasource.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';
import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';

/// Contract between domain and data layers for the chat feature.
abstract class ChatRepository {
  // User Chat
  Future<ApiResult<String>> openChat(String specialistId);
  Future<ApiResult<ChatMessagesPage>> getMessages(String conversationId, {int page = 1});
  Future<ApiResult<UserConversation?>> getUserChat();
  Future<ApiResult<ChatMessage>> sendMedia({
    required String conversationId,
    required List<XFile> files,
  });

  // Specialist Chat
  Future<ApiResult<ConversationsPageResult>> getSpecialistChats({
    int page,
    int limit,
  });
  Future<ApiResult<String>> openSpecialistChat(String userId);
  Future<ApiResult<ChatMessagesPage>> getSpecialistMessages(String conversationId, {int page = 1});
  Future<ApiResult<ChatMessage>> sendSpecialistMedia({
    required String conversationId,
    required List<XFile> files,
  });
}
