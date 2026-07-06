import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class AppBackHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Widget? trailingWidget;
  final bool? canBack;

  const AppBackHeader({
    super.key,
    required this.title,
    this.onBackPressed,
    this.trailingWidget, this.canBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ((canBack?? true) && (onBackPressed != null || Navigator.of(context).canPop()))
                  ? InkWell(
                      onTap: onBackPressed ??
                          () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                      borderRadius: BorderRadius.circular(24.r),
                      child: Icon(
                        Icons.chevron_left,
                        color: AppColors.textPrimary,
                        size: 32.sp,
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
          Text(
            title,
            style: TextStyleManager.heading2,
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: trailingWidget ?? const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
