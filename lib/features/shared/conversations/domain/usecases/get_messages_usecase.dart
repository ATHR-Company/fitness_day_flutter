import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/data/datasources/chat_remote_datasource.dart';
import 'package:fitness_day/features/shared/conversations/domain/repositories/chat_repository.dart';

/// Fetches the message history for an existing conversation.
///
/// Usage:
///   final result = await getMessagesUseCase(conversationId, page: 1);
class GetMessagesUseCase {
  final ChatRepository _repository;

  const GetMessagesUseCase(this._repository);

  Future<ApiResult<ChatMessagesPage>> call(String conversationId, {int page = 1}) {
    return _repository.getMessages(conversationId, page: page);
  }
}
