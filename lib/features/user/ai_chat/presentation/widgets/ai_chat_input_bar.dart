import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Composer of the AI coach screen. The send button is disabled — and greyed
/// out — while a reply is still being generated.
class AiChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const AiChatInputBar({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: AppColors.backgroundTint,
      child: Container(
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
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
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
            GestureDetector(
              onTap: isSending ? null : onSend,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: isSending ? AppColors.divider : AppColors.primary,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  'conversations.send'.tr(),
                  style: TextStyleManager.style11Medium
                      .copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
