import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMorePressed;

  const SectionHeader({
    Key? key,
    required this.title,
    this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyleManager.heading1.copyWith(
            color: AppColors.black,
          ),
        ),
        if (onMorePressed != null)
          GestureDetector(
            onTap: onMorePressed,
            child: Row(
              children: [
                Text(
                  "home.see_more".tr(),
                  style: TextStyleManager.style12Regular.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_double_arrow_left_rounded,
                  color: AppColors.primary,
                  size: 16.w,
                ),
              ],
            ),
          )
        else
          const SizedBox(),
      ],
    );
  }
}
