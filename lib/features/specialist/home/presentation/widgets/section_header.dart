import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMorePressed;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.onMorePressed,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyleManager.style14Medium),
        if (trailing != null)
          trailing!
        else if (onMorePressed != null)
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
                isRtl
                    ? SvgPicture.asset(
                        SvgIcons.moreArrows,
                        width: 17.w,
                        height: 10.h,
                      )
                    : Transform.flip(
                        flipX: true,
                        child: SvgPicture.asset(
                          SvgIcons.moreArrows,
                          width: 17.w,
                          height: 10.h,
                        ),
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
