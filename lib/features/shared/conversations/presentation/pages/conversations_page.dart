import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/widgets/app_back_header.dart';
import 'package:fitness_day/features/shared/widgets/app_search_bar.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/chat_details_page.dart';

class ConversationsPage extends StatefulWidget {
  final bool isEmpty;

  const ConversationsPage({
    super.key,
    this.isEmpty = false, // Set to false to see populated state
  });

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              Expanded(
                child: widget.isEmpty
                    ? _buildEmptyState()
                    : _buildPopulatedState(),
              ),
            ],
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
            color: AppColors.primary.withValues(alpha: 0.2), // Faded green
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
              height: 1.5,
            ),
          ),
          SizedBox(height: 60.h), // Push slightly up
        ],
      ),
    );
  }

  Widget _buildPopulatedState() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: AppSearchBar(
            hintText: 'conversations.search_hint'.tr(),
            controller: _searchController,
            onChanged: (val) {},
          ),
        ),
        SizedBox(height: 24.h),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            children: [
              // New Conversations Section
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'conversations.new_conversations'.tr(),
                    style: TextStyleManager.heading2.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              _buildConversationCard(
                name: 'conversations.dummy_name'.tr(),
                message: 'conversations.dummy_message_1'.tr(),
                time: '''09:00 ${'shared_mock_pm'.tr()}''',
                isOnline: true,
                isRead: false,
              ),

              SizedBox(height: 24.h),

              // Previous Conversations Section
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'conversations.previous_conversations'.tr(),
                    style: TextStyleManager.heading2.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              _buildConversationCard(
                name: 'conversations.dummy_name'.tr(),
                message: 'conversations.dummy_message_1'.tr(),
                time: '''09:00 ${'shared_mock_pm'.tr()}''',
                isOnline: true,
                isRead: true,
              ),
              SizedBox(height: 12.h),
              _buildConversationCard(
                name: 'conversations.dummy_name'.tr(),
                message: 'conversations.dummy_message_1'.tr(),
                time: '''09:00 ${'shared_mock_pm'.tr()}''',
                isOnline: false,
                isRead: true,
              ),
              SizedBox(height: 12.h),
              _buildConversationCard(
                name: 'conversations.dummy_name'.tr(),
                message: 'conversations.dummy_message_1'.tr(),
                time: '''09:00 ${'shared_mock_pm'.tr()}''',
                isOnline: true,
                isRead: true,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConversationCard({
    required String name,
    required String message,
    required String time,
    required bool isOnline,
    required bool isRead,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatDetailsPage()),
        );
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
            // Avatar with Online dot (Right side in RTL)
            Stack(
              children: [
                CircleAvatar(
                  radius: 25.r,
                  backgroundImage: const NetworkImage(
                    'https://img.magnific.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?semt=ais_hybrid&w=740&q=80',
                  ), // dummy
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 4.w,
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
                    name,
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        isRead ? Icons.done_all : Icons.check,
                        color: isRead
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.textSecondary.withValues(alpha: 0.5),
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyleManager.heading3.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Time and Arrow (Left side in RTL)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 14.sp,
                ),
                SizedBox(height: 12.h),
                Text(
                  time,
                  style: TextStyleManager.heading3.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
