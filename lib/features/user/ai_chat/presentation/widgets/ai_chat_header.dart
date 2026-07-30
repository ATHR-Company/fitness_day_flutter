import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

/// Header of the AI coach screen — back button, avatar and "online now".
class AiChatHeader extends StatelessWidget {
  const AiChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Icon(Icons.arrow_back_ios,
                color: AppColors.black, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          const _CoachAvatar(),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ai_chat.coach_name'.tr(),
                style: TextStyleManager.style14Bold
                    .copyWith(color: AppColors.black),
              ),
              Text(
                'ai_chat.online_now'.tr(),
                style: TextStyleManager.style10Medium
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoachAvatar extends StatelessWidget {
  const _CoachAvatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
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
    );
  }
}
