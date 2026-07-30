import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/data/datasources/chat_remote_datasource.dart';
import 'package:fitness_day/features/shared/conversations/domain/repositories/chat_repository.dart';

class GetSpecialistChatsUseCase {
  final ChatRepository _repository;

  const GetSpecialistChatsUseCase(this._repository);

  Future<ApiResult<ConversationsPageResult>> call({
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getSpecialistChats(page: page, limit: limit);
  }
}
