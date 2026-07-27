import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/domain/repositories/chat_repository.dart';

/// Opens or retrieves an existing conversation with [specialistId].
/// Returns the [conversationId] to use for subsequent calls.
///
/// Usage:
///   final result = await openChatUseCase(specialistId);
class OpenChatUseCase {
  final ChatRepository _repository;

  const OpenChatUseCase(this._repository);

  Future<ApiResult<String>> call(String specialistId) {
    return _repository.openChat(specialistId);
  }
}
