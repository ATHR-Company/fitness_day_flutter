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

  const ConversationsLoaded({
    required this.conversations,
    required this.filteredConversations,
    this.searchQuery = '',
  });

  ConversationsLoaded copyWith({
    List<UserConversation>? conversations,
    List<UserConversation>? filteredConversations,
    String? searchQuery,
  }) {
    return ConversationsLoaded(
      conversations: conversations ?? this.conversations,
      filteredConversations: filteredConversations ?? this.filteredConversations,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [conversations, filteredConversations, searchQuery];
}

class ConversationsError extends ConversationsState {
  final String message;

  const ConversationsError(this.message);

  @override
  List<Object?> get props => [message];
}
