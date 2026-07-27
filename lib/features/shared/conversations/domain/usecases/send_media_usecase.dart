import 'package:image_picker/image_picker.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';
import 'package:fitness_day/features/shared/conversations/domain/repositories/chat_repository.dart';

/// Uploads media files for a chat message.
///
/// Call: `await sendMediaUseCase(conversationId: id, files: pickedFiles)`
class SendMediaUseCase {
  final ChatRepository _repository;

  const SendMediaUseCase(this._repository);

  Future<ApiResult<ChatMessage>> call({
    required String conversationId,
    required List<XFile> files,
  }) {
    return _repository.sendMedia(
      conversationId: conversationId,
      files: files,
    );
  }
}
