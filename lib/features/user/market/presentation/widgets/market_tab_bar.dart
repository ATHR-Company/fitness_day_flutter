import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Tab bar switching between "Products" and "Packages" on the market screen.
class MarketTabBar extends StatelessWidget {
  final TabController controller;

  const MarketTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      child: TabBar(
        controller: controller,
        // Indicator only for the selected tab; make it slightly wider
        // than the label by using label size with negative horizontal insets.
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 4),
          insets: EdgeInsets.symmetric(horizontal: -50.w),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle:
            TextStyleManager.style13Medium.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyleManager.style13Medium,
        tabs: [
          Tab(text: 'market.tab_products'.tr()),
          Tab(text: 'market.tab_packages'.tr()),
        ],
      ),
    );
  }
}
