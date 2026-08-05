import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Placeholder shown when there is no conversation to list — either the user
/// has none, or the search matched nothing.
class ConversationsEmptyState extends StatelessWidget {
  const ConversationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
