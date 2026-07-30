import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Emoji reactions offered on long-press.
const List<String> kChatReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

/// Long-press reaction picker.
///
/// [onSelected] fires with the tapped emoji, or with null when the user taps
/// the reaction already on the message (which clears it). Dismissing the sheet
/// does not call it at all.
void showChatReactionPicker(
  BuildContext context, {
  required String? current,
  required ValueChanged<String?> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: kChatReactions.map((emoji) {
          final bool isSelected = current == emoji;
          return GestureDetector(
            onTap: () {
              Navigator.pop(sheetContext);
              onSelected(isSelected ? null : emoji);
            },
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
              ),
              child: Text(
                emoji,
                style:
                    TextStyleManager.style11Medium.copyWith(fontSize: 26.sp),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}
