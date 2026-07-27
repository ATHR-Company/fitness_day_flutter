import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';
import 'package:fitness_day/features/shared/conversations/domain/repositories/chat_repository.dart';

class GetSpecialistChatsUseCase {
  final ChatRepository _repository;

  const GetSpecialistChatsUseCase(this._repository);

  Future<ApiResult<List<UserConversation>>> call() {
    return _repository.getSpecialistChats();
  }
}
