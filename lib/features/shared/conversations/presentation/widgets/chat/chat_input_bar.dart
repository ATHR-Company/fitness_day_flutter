import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/utils/no_script_input_formatter.dart';
import 'package:fitness_day/features/shared/conversations/presentation/utils/chat_time_format.dart';

/// Bottom bar of the chat: the composer, or the recording row while a voice
/// note is being captured.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  final Duration recordedFor;

  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onStartRecording;
  final VoidCallback onCancelRecording;
  final VoidCallback onSendRecording;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isRecording,
    required this.recordedFor,
    required this.onSend,
    required this.onAttach,
    required this.onStartRecording,
    required this.onCancelRecording,
    required this.onSendRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: AppColors.backgroundTint,
      child: isRecording
          ? _RecordingRow(
              recordedFor: recordedFor,
              onCancel: onCancelRecording,
              onSend: onSendRecording,
            )
          : _ComposerRow(
              controller: controller,
              onSend: onSend,
              onAttach: onAttach,
              onStartRecording: onStartRecording,
            ),
    );
  }
}

class _ComposerRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onStartRecording;

  const _ComposerRow({
    required this.controller,
    required this.onSend,
    required this.onAttach,
    required this.onStartRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              inputFormatters: [NoScriptInputFormatter()],
              decoration: InputDecoration(
                hintText: 'conversations.write_message_hint'.tr(),
                // Same as the AI composer: a wrapping hint grows the empty
                // field and drags the placeholder off the vertical centre.
                hintMaxLines: 1,
                hintStyle: TextStyleManager.style10Medium.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAttach,
            child: Icon(Icons.attach_file,
                color: AppColors.textSecondary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          // Mic while the field is empty, send button once the user types.
          // Listening to the controller here keeps the keystroke rebuilds
          // inside this row instead of the whole page.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.trim().isEmpty) {
                return GestureDetector(
                  onTap: onStartRecording,
                  child: Icon(Icons.mic,
                      color: AppColors.textSecondary, size: 22.sp),
                );
              }
              return GestureDetector(
                onTap: onSend,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Text(
                    'conversations.send'.tr(),
                    style: TextStyleManager.style11Medium
                        .copyWith(color: AppColors.white),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecordingRow extends StatelessWidget {
  final Duration recordedFor;
  final VoidCallback onCancel;
  final VoidCallback onSend;

  const _RecordingRow({
    required this.recordedFor,
    required this.onCancel,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onCancel,
            child:
                Icon(Icons.delete_outline, color: AppColors.error, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 10.w,
            height: 10.w,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${'conversations.recording'.tr()}  ${formatChatDuration(recordedFor)}',
            style: TextStyleManager.style11Medium
                .copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.send_rounded, color: AppColors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}
