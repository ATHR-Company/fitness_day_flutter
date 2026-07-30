import 'package:image_picker/image_picker.dart';
import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/data/datasources/chat_remote_datasource.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';
import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';
import 'package:fitness_day/features/shared/conversations/domain/repositories/chat_repository.dart';

/// Bridges the domain interface with the data source.
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _dataSource;

  const ChatRepositoryImpl(this._dataSource);

  // ── User Chat ─────────────────────────────────────────────────────────────

  @override
  Future<ApiResult<String>> openChat(String specialistId) async {
    try {
      final conversationId = await _dataSource.openChat(specialistId);
      return Success(conversationId);
    } catch (error) {
      return FailureResult(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<ChatMessagesPage>> getMessages(String conversationId, {int page = 1}) async {
    try {
      final result = await _dataSource.getMessages(conversationId, page: page);
      return Success(result);
    } catch (error) {
      return FailureResult(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<UserConversation?>> getUserChat() async {
    try {
      final conversation = await _dataSource.getUserChat();
      return Success(conversation);
    } catch (error) {
      return FailureResult(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<ChatMessage>> sendMedia({
    required String conversationId,
    required List<XFile> files,
  }) async {
    try {
      final message = await _dataSource.sendMedia(
        conversationId: conversationId,
        files: files,
      );
      return Success(message);
    } catch (error) {
      return FailureResult(ErrorHandler.handle(error));
    }
  }

  // ── Specialist Chat ───────────────────────────────────────────────────────

  @override
  Future<ApiResult<ConversationsPageResult>> getSpecialistChats({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result =
          await _dataSource.getSpecialistChats(page: page, limit: limit);
      return Success(result);
    } catch (error) {
      return FailureResult(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<String>> openSpecialistChat(String userId) async {
    try {
      final conversationId = await _dataSource.openSpecialistChat(userId);
      return Success(conversationId);
    } catch (error) {
      return FailureResult(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<ChatMessagesPage>> getSpecialistMessages(
      String conversationId, {int page = 1}) async {
    try {
      final result = await _dataSource.getSpecialistMessages(conversationId, page: page);
      return Success(result);
    } catch (error) {
      return FailureResult(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<ChatMessage>> sendSpecialistMedia({
    required String conversationId,
    required List<XFile> files,
  }) async {
    try {
      final message = await _dataSource.sendSpecialistMedia(
        conversationId: conversationId,
        files: files,
      );
      return Success(message);
    } catch (error) {
      return FailureResult(ErrorHandler.handle(error));
    }
  }
}
