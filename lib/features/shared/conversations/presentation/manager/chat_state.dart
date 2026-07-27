import 'package:equatable/equatable.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';
import 'package:fitness_day/features/shared/conversations/domain/entities/chat_message.dart';

/// All possible states for the chat screen.
sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Loading the initial message history from REST API.
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Messages loaded successfully — socket is active and ready.
///
/// [messages] is ordered oldest-first (as returned by the API)
/// so the ListView shows the oldest at the top.
/// [conversationId] is kept here so the Cubit can use it when sending.
class ChatLoaded extends ChatState {
  final String conversationId;
  final List<ChatMessage> messages;
  final bool isOtherPartyTyping;

  /// Name / avatar / online flag of the person on the other side, as returned
  /// by the messages endpoint. Drives the chat header.
  final ConversationOtherParty? otherParty;

  /// The last page that was fetched from the server.
  final int currentPage;

  /// Total number of pages returned by the server.
  final int totalPages;

  /// True while fetching older messages (page > 1).
  final bool isLoadingMore;

  const ChatLoaded({
    required this.conversationId,
    required this.messages,
    this.otherParty,
    this.isOtherPartyTyping = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
  });

  bool get hasMore => currentPage < totalPages;

  ChatLoaded copyWithNewMessage(ChatMessage msg) {
    return ChatLoaded(
      conversationId: conversationId,
      otherParty: otherParty,
      messages: [...messages, msg],
      isOtherPartyTyping: isOtherPartyTyping,
      currentPage: currentPage,
      totalPages: totalPages,
      isLoadingMore: isLoadingMore,
    );
  }

  /// Prepends [olderMessages] (older page) to the front of the list.
  ChatLoaded copyWithOlderMessages({
    required List<ChatMessage> olderMessages,
    required int newPage,
    required int newTotalPages,
  }) {
    return ChatLoaded(
      conversationId: conversationId,
      otherParty: otherParty,
      messages: [...olderMessages, ...messages],
      isOtherPartyTyping: isOtherPartyTyping,
      currentPage: newPage,
      totalPages: newTotalPages,
      isLoadingMore: false,
    );
  }

  ChatLoaded copyWithLoadingMore() {
    return ChatLoaded(
      conversationId: conversationId,
      otherParty: otherParty,
      messages: messages,
      isOtherPartyTyping: isOtherPartyTyping,
      currentPage: currentPage,
      totalPages: totalPages,
      isLoadingMore: true,
    );
  }

  /// Returns a new state with the message identified by [messageId]
  /// marked as delivered (if it is an outgoing message and not already seen).
  /// Fallback: if exact [messageId] is not found (because the local bubble is still using an optimistic ID),
  /// updates the matching optimistic message's ID and status.
  ChatLoaded copyWithMessageDelivered(String messageId) {
    final hasExactMatch = messages.any((m) => m.id == messageId);
    bool matchedOptimistic = false;

    final updatedMessages = messages.map((m) {
      if (!m.isMine || m.status == MessageStatus.seen) return m;

      if (hasExactMatch) {
        if (m.id == messageId) {
          return m.copyWith(status: MessageStatus.delivered);
        }
      } else {
        if (!matchedOptimistic && m.id.startsWith('optimistic_')) {
          matchedOptimistic = true;
          return m.copyWith(id: messageId, status: MessageStatus.delivered);
        }
      }
      return m;
    }).toList();

    return ChatLoaded(
      conversationId: conversationId,
      otherParty: otherParty,
      messages: updatedMessages,
      isOtherPartyTyping: isOtherPartyTyping,
      currentPage: currentPage,
      totalPages: totalPages,
      isLoadingMore: isLoadingMore,
    );
  }

  ChatLoaded copyWithTyping(bool isTyping) {
    return ChatLoaded(
      conversationId: conversationId,
      otherParty: otherParty,
      messages: messages,
      isOtherPartyTyping: isTyping,
      currentPage: currentPage,
      totalPages: totalPages,
      isLoadingMore: isLoadingMore,
    );
  }

  /// Marks ALL outgoing (isMine) messages as [MessageStatus.seen].
  ///
  /// Called when the server emits `chat:read`, meaning the other party
  /// has opened the conversation and read all our messages.
  ChatLoaded copyWithAllMessagesSeen() {
    return ChatLoaded(
      conversationId: conversationId,
      otherParty: otherParty,
      isOtherPartyTyping: isOtherPartyTyping,
      currentPage: currentPage,
      totalPages: totalPages,
      isLoadingMore: isLoadingMore,
      messages: messages.map((msg) {
        if (msg.isMine && msg.status != MessageStatus.seen) {
          return msg.copyWith(status: MessageStatus.seen);
        }
        return msg;
      }).toList(),
    );
  }

  /// Generic copy helper — used internally so every state transition
  /// (including incoming socket events) preserves pagination/loading
  /// flags unless explicitly overridden.
  ChatLoaded copyWith({
    String? conversationId,
    List<ChatMessage>? messages,
    ConversationOtherParty? otherParty,
    bool? isOtherPartyTyping,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return ChatLoaded(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      otherParty: otherParty ?? this.otherParty,
      isOtherPartyTyping: isOtherPartyTyping ?? this.isOtherPartyTyping,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        conversationId,
        messages,
        otherParty,
        isOtherPartyTyping,
        currentPage,
        totalPages,
        isLoadingMore,
      ];
}

/// Something went wrong loading history or opening the chat.
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}