import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';
import 'package:fitness_day/features/shared/conversations/domain/usecases/get_specialist_chats_usecase.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final GetSpecialistChatsUseCase _getSpecialistChatsUseCase;

  ConversationsCubit({
    required GetSpecialistChatsUseCase getSpecialistChatsUseCase,
  })  : _getSpecialistChatsUseCase = getSpecialistChatsUseCase,
        super(const ConversationsInitial());

  Future<void> fetchSpecialistConversations() async {
    debugPrint('[ConversationsCubit] fetchSpecialistConversations...');
    emit(const ConversationsLoading());

    final result = await _getSpecialistChatsUseCase();

    if (result is FailureResult) {
      final msg = (result as FailureResult).failure.message;
      debugPrint('[ConversationsCubit] ❌ fetch failed: $msg');
      emit(ConversationsError(msg));
      return;
    }

    final conversations = (result as Success<List<UserConversation>>).data;
    debugPrint('[ConversationsCubit] ✅ loaded ${conversations.length} conversations');

    emit(ConversationsLoaded(
      conversations: conversations,
      filteredConversations: conversations,
    ));
  }

  void searchConversations(String query) {
    final currentState = state;
    if (currentState is! ConversationsLoaded) return;

    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      emit(currentState.copyWith(
        filteredConversations: currentState.conversations,
        searchQuery: '',
      ));
      return;
    }

    final filtered = currentState.conversations.where((conv) {
      final name = conv.otherParty?.name.toLowerCase() ?? '';
      final lastMsg = conv.lastMessageText?.toLowerCase() ?? '';
      return name.contains(q) || lastMsg.contains(q);
    }).toList();

    emit(currentState.copyWith(
      filteredConversations: filtered,
      searchQuery: query,
    ));
  }
}
