import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/data/datasources/chat_remote_datasource.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';
import 'package:fitness_day/features/shared/conversations/domain/usecases/get_specialist_chats_usecase.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final GetSpecialistChatsUseCase _getSpecialistChatsUseCase;

  ConversationsCubit({
    required GetSpecialistChatsUseCase getSpecialistChatsUseCase,
  })  : _getSpecialistChatsUseCase = getSpecialistChatsUseCase,
        super(const ConversationsInitial());

  static const int _pageSize = 20;

  Future<void> fetchSpecialistConversations() async {
    debugPrint('[ConversationsCubit] fetchSpecialistConversations...');
    // Keep the current search text across a refresh — coming back from a chat
    // re-fetches the list, and clearing the filter under the user would be a
    // surprise.
    final String query =
        state is ConversationsLoaded ? (state as ConversationsLoaded).searchQuery : '';

    emit(const ConversationsLoading());

    final result = await _getSpecialistChatsUseCase(page: 1, limit: _pageSize);

    if (result is FailureResult) {
      final msg = (result as FailureResult).failure.message;
      debugPrint('[ConversationsCubit] ❌ fetch failed: $msg');
      emit(ConversationsError(msg));
      return;
    }

    final data = (result as Success<ConversationsPageResult>).data;
    debugPrint(
        '[ConversationsCubit] ✅ loaded ${data.conversations.length} conversations  page=${data.page}/${data.totalPages}');

    emit(ConversationsLoaded(
      conversations: data.conversations,
      filteredConversations: _filter(data.conversations, query),
      searchQuery: query,
      page: data.page,
      totalPages: data.totalPages,
    ));
  }

  /// Appends the next page. Safe to call on every scroll tick — it returns
  /// immediately when there is nothing more to fetch or a fetch is already in
  /// flight.
  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! ConversationsLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    final int nextPage = currentState.page + 1;
    debugPrint('[ConversationsCubit] loading page $nextPage...');
    emit(currentState.copyWith(isLoadingMore: true));

    final result =
        await _getSpecialistChatsUseCase(page: nextPage, limit: _pageSize);
    if (isClosed) return;

    if (result is FailureResult) {
      debugPrint(
          '[ConversationsCubit] ❌ page $nextPage failed: ${(result as FailureResult).failure.message}');
      // Keep what is already on screen; scrolling again retries.
      emit(currentState.copyWith(isLoadingMore: false));
      return;
    }

    final data = (result as Success<ConversationsPageResult>).data;

    // Guard against a duplicate id slipping in: a conversation whose last
    // message arrives between two page requests is re-sorted server-side and
    // can be returned on both pages.
    final Set<String?> seen =
        currentState.conversations.map((c) => c.conversationId).toSet();
    final List<UserConversation> merged = [
      ...currentState.conversations,
      ...data.conversations.where((c) => !seen.contains(c.conversationId)),
    ];

    emit(currentState.copyWith(
      conversations: merged,
      filteredConversations: _filter(merged, currentState.searchQuery),
      page: data.page,
      totalPages: data.totalPages,
      isLoadingMore: false,
    ));
  }

  /// Search runs over the pages loaded so far — the endpoint takes no search
  /// term, so a match sitting on an unfetched page only appears once the user
  /// has scrolled far enough to load it.
  void searchConversations(String query) {
    final currentState = state;
    if (currentState is! ConversationsLoaded) return;

    emit(currentState.copyWith(
      filteredConversations: _filter(currentState.conversations, query),
      searchQuery: query,
    ));
  }

  List<UserConversation> _filter(
    List<UserConversation> conversations,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return conversations;

    return conversations.where((conv) {
      final name = conv.otherParty?.name.toLowerCase() ?? '';
      final lastMsg = conv.lastMessageText?.toLowerCase() ?? '';
      return name.contains(q) || lastMsg.contains(q);
    }).toList();
  }
}
