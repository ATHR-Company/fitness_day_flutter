import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/data/datasources/chat_remote_datasource.dart';
import 'package:fitness_day/features/shared/conversations/domain/repositories/chat_repository.dart';

class GetSpecialistMessagesUseCase {
  final ChatRepository _repository;

  const GetSpecialistMessagesUseCase(this._repository);

  Future<ApiResult<ChatMessagesPage>> call(String conversationId, {int page = 1}) {
    return _repository.getSpecialistMessages(conversationId, page: page);
  }
}
