import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';

class MessageIconButton extends StatelessWidget {
  final VoidCallback? onTap;

  const MessageIconButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: IconButton(
        icon: SvgPicture.asset(SvgIcons.chatIcon, height: 16.h, colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn)),
        onPressed: onTap,
      ),
    );
  }
}
