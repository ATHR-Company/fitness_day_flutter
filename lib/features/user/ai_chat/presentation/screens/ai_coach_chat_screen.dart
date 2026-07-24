import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/constant/app_env.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/ai_chat/presentation/services/fitness_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Message model ────────────────────────────────────────────────────────────

class _ChatMessage {
  final String content;
  final bool isMe;
  final DateTime time;
  final bool isTyping;

  const _ChatMessage({
    required this.content,
    required this.isMe,
    required this.time,
    this.isTyping = false,
  });
}

// ── Screen ───────────────────────────────────────────────────────────────────

class AiCoachChatScreen extends StatefulWidget {
  const AiCoachChatScreen({super.key});

  @override
  State<AiCoachChatScreen> createState() => _AiCoachChatScreenState();
}

class _AiCoachChatScreenState extends State<AiCoachChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FitnessAiService _service =
      FitnessAiService(apiKey: AppEnv.openRouterApiKey);

  // In-memory conversation — not persisted
  final List<_ChatMessage> _messages = [];
  final List<Map<String, String>> _history = [];

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Welcome message — localized to the app language
    _messages.add(_ChatMessage(
      content: 'ai_chat.welcome'.tr(),
      isMe: false,
      time: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();

    // Add user message
    setState(() {
      _messages.add(_ChatMessage(
        content: text,
        isMe: true,
        time: DateTime.now(),
      ));
      _isSending = true;
      // Show typing indicator
      _messages.add(_ChatMessage(
        content: '',
        isMe: false,
        time: DateTime.now(),
        isTyping: true,
      ));
    });
    _scrollToBottom();

    // Build history for API
    _history.add({'role': 'user', 'content': text});

    try {
      final reply = await _service.sendMessage(_history);
      _history.add({'role': 'assistant', 'content': reply});

      if (!mounted) return;
      setState(() {
        // Remove typing indicator
        _messages.removeWhere((m) => m.isTyping);
        _messages.add(_ChatMessage(
          content: reply,
          isMe: false,
          time: DateTime.now(),
        ));
        _isSending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.isTyping);
        _messages.add(_ChatMessage(
          content: '⚠️ ${e.toString().replaceFirst('Exception: ', '')}',
          isMe: false,
          time: DateTime.now(),
        ));
        _isSending = false;
      });
      // Remove failed message from history
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                if (i == 0 || !_isSameDay(_messages[i - 1].time, msg.time)) {
                  return Column(
                    children: [
                      _buildDateHeader(msg.time),
                      SizedBox(height: 16.h),
                      _buildBubble(msg),
                    ],
                  );
                }
                return _buildBubble(msg);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        bottom: 12.h,
        left: 16.w,
        right: 16.w,
      ),
      decoration: const BoxDecoration(color: AppColors.backgroundTint),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child:Icon(Icons.arrow_back_ios,
                color: AppColors.black, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Stack(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: AppImage(AppImages.ai, fit: BoxFit.cover),
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
                    border: Border.all(color: AppColors.backgroundTint, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ai_chat.coach_name'.tr(),
                style: TextStyleManager.style14Bold.copyWith(
                  color: AppColors.black,
                ),
              ),
              Text(
                'ai_chat.online_now'.tr(),
                style: TextStyleManager.style10Medium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Date divider ─────────────────────────────────────────────────────────

  Widget _buildDateHeader(DateTime time) {
    return Center(
      child: Text(
        'conversations.today'.tr(),
        style: TextStyleManager.style11Medium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Bubble ───────────────────────────────────────────────────────────────

  Widget _buildBubble(_ChatMessage msg) {
    if (msg.isTyping) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.more_horiz, color: AppColors.primary, size: 20.sp),
          ),
        ),
      );
    }

    final timeStr = DateFormat('hh:mm', 'en').format(msg.time);
    final amPm = msg.time.hour >= 12 ? 'shared_mock_pm'.tr() : 'shared_mock_am'.tr();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Align(
        alignment: msg.isMe
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 0.75.sw),
          child: Column(
            crossAxisAlignment: msg.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: msg.isMe
                      ? AppColors.white
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: msg.isMe
                        ? Radius.circular(16.r)
                        : Radius.circular(4.r),
                    bottomRight: msg.isMe
                        ? Radius.circular(4.r)
                        : Radius.circular(16.r),
                  ),
                  border: msg.isMe
                      ? Border.all(color: AppColors.divider, width: 0.5)
                      : null,
                ),
                child: Text(
                  msg.content,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.black,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$timeStr $amPm',
                    style: TextStyleManager.style10Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (msg.isMe) ...[
                    SizedBox(width: 4.w),
                    Icon(Icons.done_all, size: 14.sp, color: AppColors.primary),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Input bar ────────────────────────────────────────────────────────────

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
                      controller: _controller,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'ai_chat.input_hint'.tr(),
                        hintStyle: TextStyleManager.style10Medium.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Send Button
                  GestureDetector(
                    onTap: _isSending ? null : _sendMessage,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: _isSending
                            ? AppColors.divider
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Text(
                        'conversations.send'.tr(),
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.white,
                        ),
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
