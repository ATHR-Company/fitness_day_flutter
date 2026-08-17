import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Shared app bar used across the Challenges feature screens.
///
/// Handles a leading back button, a centered title, and an optional
/// trailing action (e.g. an options menu). Fully direction-agnostic: it
/// mirrors correctly for both LTR and RTL locales.
class ChallengeAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const ChallengeAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 20.sp,
              color: AppColors.black,
            ),
          ),
          // Expanded rather than Spacer-Text-Spacer: the leading icon and the
          // trailing slot are the same width, so the title still reads centred,
          // but now it can shrink instead of running under the ⋮ menu.
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
          ),
          trailing ?? SizedBox(width: 20.sp),
        ],
      ),
    );
  }
}
