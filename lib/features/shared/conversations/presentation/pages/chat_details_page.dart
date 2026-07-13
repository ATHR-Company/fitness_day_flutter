import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';

import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';

import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

class ChatDetailsPage extends StatefulWidget {
  final String? title;
  final bool isAi;
  final bool isSpecialist;

  const ChatDetailsPage({
    super.key,
    this.title,
    this.isAi = false,
    this.isSpecialist = false,
  });

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LoaderHud(
        isCall: false,
        child: TopCenteredConstrainedBox(
          horizontalPadding: 0,
          child: Column(
            children: [
              _buildHeader(context),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  children: [
                    // Date Header
                    Center(
                      child: Text(
                        'conversations.today'.tr(),
                        style: TextStyleManager.style11Medium,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Other Person's Message (Green Bubble on Right in RTL)
                    _buildMessageBubble(
                      time: '''10:22 ${'shared_mock_am'.tr()}''',
                      message: widget.isAi
                          ? 'conversations.dummy_welcome'.tr()
                          : (widget.isSpecialist
                                ? 'conversations.dummy_welcome'.tr()
                                : 'conversations.dummy_message_1'.tr()),

                      isMe: false,
                    ),

                    SizedBox(height: 16.h),

                    // My Message (Grey Bubble on Left in RTL)
                    _buildMessageBubble(
                      time: '''10:22 ${'shared_mock_am'.tr()}''',
                      message: widget.isAi || widget.isSpecialist
                          ? 'conversations.dummy_reply'.tr()
                          : 'conversations.dummy_message_2'.tr(),

                      isMe: true,
                      isRead: true,
                    ),

                    SizedBox(height: 16.h),

                    // Typing indicator (Mock)
                    Align(
                      alignment: AlignmentDirectional
                          .centerStart, // 'start' in RTL is right
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),

                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.more_horiz,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Input Area
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: const BoxDecoration(color: AppColors.backgroundTint),

      child: Column(
        children: [
          SizedBox(height: 30.h),
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios, // < points left
                  color: AppColors.black,
                  size: 20.sp,
                ),
              ),
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: const NetworkImage(
                      'https://img.magnific.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?semt=ais_hybrid&w=740&q=80',
                    ),
                  ),
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.isAi
                        ? AppImage(AppImages.ai, fit: BoxFit.cover)
                        : (widget.isSpecialist
                              ? AppImage(
                                  SvgIcons.logo,
                                  fit: BoxFit.cover,
                                )
                              : AppImage(
                                  'https://img.magnific.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?semt=ais_hybrid&w=740&q=80',
                                  fit: BoxFit.cover,
                                )),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.backgroundTint,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              // Name
              Text(
                widget.title ?? 'conversations.dummy_name'.tr(),
                style: TextStyleManager.style14Bold.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required String time,
    required bool isMe,
    bool isRead = false,
  }) {
    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,

      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,

        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 0.75.sw),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.white
                  : AppColors.primary.withValues(alpha: 0.1),

              borderRadius: BorderRadius.circular(16.r).copyWith(
                topLeft: Radius.circular(
                  isMe ? 0 : 16.r,
                ), // Flat top-left for me (left side)
                topRight: Radius.circular(
                  isMe ? 16.r : 0,
                ), // Flat top-right for other person (right side)
              ),
              boxShadow: [
                if (isMe)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Text(message, style: TextStyleManager.style11Medium),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMe) ...[
                Icon(
                  Icons.done_all,
                  color: isRead ? AppColors.primary : AppColors.textSecondary,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
              ],
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
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: AppColors.backgroundTint,
      child: Row(
        children: [
          // Text Input
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.white, // White background for the text field
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'conversations.write_message_hint'.tr(),
                        hintStyle: TextStyleManager.style10Medium.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.attach_file,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Icon(Icons.mic, color: AppColors.textSecondary, size: 20.sp),
                  SizedBox(width: 12.w),
                  // Send Button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 7.h,
                    ),

                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Text(
                      'conversations.send'.tr(),
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
