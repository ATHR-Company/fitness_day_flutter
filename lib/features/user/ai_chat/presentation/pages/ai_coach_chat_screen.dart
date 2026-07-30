import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/constant/app_env.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/ai_chat/presentation/models/ai_chat_message.dart';
import 'package:fitness_day/features/user/ai_chat/presentation/services/fitness_ai_service.dart';
import 'package:fitness_day/features/user/ai_chat/presentation/widgets/ai_chat_bubble.dart';
import 'package:fitness_day/features/user/ai_chat/presentation/widgets/ai_chat_header.dart';
import 'package:fitness_day/features/user/ai_chat/presentation/widgets/ai_chat_input_bar.dart';

/// AI coach chat. The conversation lives in memory only — there is no backend
/// behind it, just the model call in [FitnessAiService].
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

  /// What is on screen.
  final List<AiChatMessage> _messages = [];

  /// What is sent to the model — role/content pairs, no UI concerns.
  final List<Map<String, String>> _history = [];

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(AiChatMessage(
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
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _addCoachMessage(String content) {
    setState(() {
      _messages.add(AiChatMessage(
        content: content,
        isMe: false,
        time: DateTime.now(),
      ));
      _isSending = false;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;
    _controller.clear();

    setState(() {
      _messages.add(AiChatMessage(
        content: text,
        isMe: true,
        time: DateTime.now(),
      ));
      _isSending = true;
    });
    _scrollToBottom();

    _history.add({'role': 'user', 'content': text});

    try {
      final String reply = await _service.sendMessage(_history);
      if (!mounted) return;
      _history.add({'role': 'assistant', 'content': reply});
      _addCoachMessage(reply);
    } catch (e) {
      if (!mounted) return;
      // Drop the turn that failed so the next attempt isn't sent twice.
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
      _addCoachMessage('⚠️ ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const AiChatHeader(),
          Expanded(child: _buildMessagesList()),
          AiChatInputBar(
            controller: _controller,
            isSending: _isSending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    // The typing bubble is an extra trailing item rather than a fake message,
    // so it never has to be filtered back out of [_messages].
    final int itemCount = _messages.length + (_isSending ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= _messages.length) return const AiChatTypingBubble();

        final message = _messages[index];
        final bool startsNewDay = index == 0 ||
            !_isSameDay(_messages[index - 1].time, message.time);

        if (!startsNewDay) return AiChatBubble(message: message);

        return Column(
          children: [
            Center(
              child: Text(
                'conversations.today'.tr(),
                style: TextStyleManager.style11Medium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            SizedBox(height: 16.h),
            AiChatBubble(message: message),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
