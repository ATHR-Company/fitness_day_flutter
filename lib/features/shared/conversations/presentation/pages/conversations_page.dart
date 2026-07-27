import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_search_bar.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/conversations_cubit.dart';
import 'package:fitness_day/features/shared/conversations/presentation/manager/conversations_state.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/chat_details_page.dart';
import 'package:fitness_day/features/shared/conversations/presentation/widgets/conversations_shimmer_loading.dart';

class ConversationsPage extends StatefulWidget {
  final bool isEmpty;
  final bool isLoading;

  const ConversationsPage({
    super.key,
    this.isEmpty = false,
    this.isLoading = false,
  });

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final TextEditingController _searchController = TextEditingController();
  late final ConversationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<ConversationsCubit>();
    _cubit.fetchSpecialistConversations();
  }

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
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
            child: Column(
              children: [
                SizedBox(height: 20.h),

                // Custom Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: AppBackHeader(title: 'conversations.title'.tr()),
                ),

                SizedBox(height: 24.h),

                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: AppSearchBar(
                    hintText: 'conversations.search_hint'.tr(),
                    controller: _searchController,
                    onChanged: (val) => _cubit.searchConversations(val),
                  ),
                ),

                SizedBox(height: 16.h),

                Expanded(
                  child: BlocBuilder<ConversationsCubit, ConversationsState>(
                    builder: (context, state) {
                      if (state is ConversationsLoading) {
                        return const ConversationsListShimmer();
                      }

                      if (state is ConversationsError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: TextStyleManager.heading3.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      if (state is ConversationsLoaded) {
                        final conversations = state.filteredConversations;

                        if (conversations.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.separated(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 8.h),
                          itemCount: conversations.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            return _buildConversationCard(
                                conversations[index]);
                          },
                        );
                      }

                      // ConversationsInitial — show shimmer briefly
                      return const ConversationsListShimmer();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble,
            size: 150.sp,
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
          SizedBox(height: 32.h),
          Text(
            'conversations.empty_title'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'conversations.empty_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }

  Widget _buildConversationCard(UserConversation conversation) {
    final otherParty = conversation.otherParty;
    final name = otherParty?.name ?? '';
    final avatar = otherParty?.avatar;
    final isOnline = otherParty?.online ?? false;
    final unreadCount = conversation.unreadCount;
    final lastMessage = conversation.displayLastMessage ?? '';
    final hasConversation = conversation.conversationId != null;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailsPage(
              title: name.isNotEmpty ? name : 'conversations.title'.tr(),
              isSpecialist: true,
              specialistId: otherParty?.id,
              conversationId: conversation.conversationId,
              avatarUrl: avatar,
              isSpecialistMode: true, // Specialist viewing client
            ),
          ),
        );
        // Refresh after returning
        if (mounted) {
          _cubit.fetchSpecialistConversations();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with online dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 25.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage:
                      avatar != null && avatar.isNotEmpty ? NetworkImage(avatar) : null,
                  child: avatar == null || avatar.isEmpty
                      ? Icon(Icons.person,
                          size: 28.sp,
                          color: AppColors.primary.withValues(alpha: 0.6))
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 2.w,
                    child: Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'conversations.unknown_client'.tr(),
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    hasConversation
                        ? (lastMessage.isNotEmpty
                            ? lastMessage
                            : 'conversations.no_messages'.tr())
                        : 'conversations.no_conversation'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Unread count or arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (unreadCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: TextStyleManager.heading3.copyWith(
                        color: AppColors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    size: 14.sp,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
