import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/domain/repositories/chat_repository.dart';

class OpenSpecialistChatUseCase {
  final ChatRepository _repository;

  const OpenSpecialistChatUseCase(this._repository);

  Future<ApiResult<String>> call(String userId) {
    return _repository.openSpecialistChat(userId);
  }
}
