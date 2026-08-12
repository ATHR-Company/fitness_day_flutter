import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_search_bar.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/conversations_cubit.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/conversations_state.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/chat_details_page.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/conversations/conversation_card.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/conversations/conversations_empty_state.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/conversations_shimmer_loading.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';

/// List of the specialist's conversations, with search.
class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ConversationsCubit _cubit;

  /// How close to the bottom the user has to get before the next page starts
  /// loading, so the spinner is rarely the thing they are looking at.
  static const double _loadMoreThreshold = 300;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<ConversationsCubit>();
    _cubit.fetchSpecialistConversations();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      // The cubit ignores this when there is no next page or one is already in
      // flight, so firing it on every tick is fine.
      _cubit.loadNextPage();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Opens the conversation, then refreshes the list so the last message and
  /// unread badge reflect what happened inside the chat.
  Future<void> _openConversation(UserConversation conversation) async {
    // The card already withholds the tap, but the rule belongs here too — an
    // archived client must not be reachable through any future entry point.
    if (conversation.isArchived) return;

    final otherParty = conversation.otherParty;
    final String name = otherParty?.name ?? '';

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailsPage(
          title: name.isNotEmpty ? name : 'conversations.title'.tr(),
          isSpecialist: true,
          specialistId: otherParty?.id,
          conversationId: conversation.conversationId,
          avatarUrl: otherParty?.avatar,
          isSpecialistMode: true,
        ),
      ),
    );

    if (mounted) _cubit.fetchSpecialistConversations();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.visitsBackgroundGradient,
          ),
          child: SafeArea(
            child: BlocBuilder<ConversationsCubit, ConversationsState>(
              builder: (context, state) {
                // Tested against the *unfiltered* list on purpose: a search that
                // matches nothing must keep the bar on screen, or there would be
                // no way to clear the query it is showing.
                final bool hasAnyConversation =
                    state is ConversationsLoaded && state.conversations.isNotEmpty;

                return Column(
                  children: [
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: AppBackHeader(title: 'conversations.title'.tr()),
                    ),
                    SizedBox(height: 24.h),
                    // Nothing to search through yet — an empty inbox shouldn't
                    // offer a search box above its own empty state.
                    if (hasAnyConversation) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: AppSearchBar(
                          hintText: 'conversations.search_hint'.tr(),
                          controller: _searchController,
                          onChanged: _cubit.searchConversations,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                    Expanded(
                      child: switch (state) {
                        ConversationsError(:final message, :final error) =>
                          AppErrorView(
                            error: error,
                            message: message,
                            onRetry: _cubit.fetchSpecialistConversations,
                          ),
                        ConversationsLoaded() => _buildList(state),
                        // Initial state also shows the shimmer — the fetch is
                        // kicked off in initState, so it is never idle for long.
                        _ => const ConversationsListShimmer(),
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(ConversationsLoaded state) {
    final conversations = state.filteredConversations;
    final bool isLoadingMore = state.isLoadingMore;

    if (conversations.isEmpty) {
      // Two different empty screens: "you have no conversations" is a state of
      // the inbox, "nothing matched" is a state of the query — telling the
      // specialist their inbox is empty while it plainly isn't would be a lie.
      final bool isSearching = state.searchQuery.trim().isNotEmpty;

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _cubit.fetchSpecialistConversations,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: isSearching
                      ? AppErrorView(
                          title: 'conversations.no_search_results_title'.tr(),
                          message: 'conversations.no_search_results'.tr(),
                        )
                      : const ConversationsEmptyState(),
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _cubit.fetchSpecialistConversations,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        // One extra row for the footer spinner while the next page loads.
        itemCount: conversations.length + (isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          if (index == conversations.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return ConversationCard(
            conversation: conversations[index],
            onTap: () => _openConversation(conversations[index]),
          );
        },
      ),
    );
  }
}

