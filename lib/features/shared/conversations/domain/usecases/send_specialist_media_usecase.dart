import 'package:image_picker/image_picker.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';
import 'package:fitness_day/features/shared/conversations/domain/repositories/chat_repository.dart';

class SendSpecialistMediaUseCase {
  final ChatRepository _repository;

  const SendSpecialistMediaUseCase(this._repository);

  Future<ApiResult<ChatMessage>> call({
    required String conversationId,
    required List<XFile> files,
  }) {
    return _repository.sendSpecialistMedia(
      conversationId: conversationId,
      files: files,
    );
  }
}
