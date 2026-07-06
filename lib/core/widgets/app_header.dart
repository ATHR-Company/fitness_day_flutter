import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/menu_icon_button.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuPressed;

  const AppHeader({super.key, required this.title, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Stack(
        children: [
          // Perfectly centered title
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Menu icon with padding on the end (left in RTL)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: MenuIconButton(onTap: onMenuPressed),
          ),
        ],
      ),
    );
  }
}
