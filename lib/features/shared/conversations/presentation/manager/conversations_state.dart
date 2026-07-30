import 'package:equatable/equatable.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';

sealed class ConversationsState extends Equatable {
  const ConversationsState();

  @override
  List<Object?> get props => [];
}

class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoaded extends ConversationsState {
  final List<UserConversation> conversations;
  final List<UserConversation> filteredConversations;
  final String searchQuery;

  /// Last page that came back from the server.
  final int page;
  final int totalPages;

  /// True while the next page is in flight, so the list can show a footer
  /// spinner without dropping what is already on screen.
  final bool isLoadingMore;

  const ConversationsLoaded({
    required this.conversations,
    required this.filteredConversations,
    this.searchQuery = '',
    this.page = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
  });

  bool get hasMore => page < totalPages;

  ConversationsLoaded copyWith({
    List<UserConversation>? conversations,
    List<UserConversation>? filteredConversations,
    String? searchQuery,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return ConversationsLoaded(
      conversations: conversations ?? this.conversations,
      filteredConversations: filteredConversations ?? this.filteredConversations,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        conversations,
        filteredConversations,
        searchQuery,
        page,
        totalPages,
        isLoadingMore,
      ];
}

class ConversationsError extends ConversationsState {
  final String message;

  const ConversationsError(this.message);

  @override
  List<Object?> get props => [message];
}
