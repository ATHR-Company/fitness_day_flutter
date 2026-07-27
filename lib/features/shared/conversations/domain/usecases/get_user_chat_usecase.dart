import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';
import 'package:fitness_day/features/shared/conversations/domain/repositories/chat_repository.dart';

/// Fetches current active user chat/conversation if exists.
class GetUserChatUseCase {
  final ChatRepository _repository;

  const GetUserChatUseCase(this._repository);

  Future<ApiResult<UserConversation?>> call() {
    return _repository.getUserChat();
  }
}
