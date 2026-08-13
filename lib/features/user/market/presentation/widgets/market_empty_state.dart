import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Nothing here" placeholder for the store's grids — same visual language as
/// the empty cart, without its call-to-action button.
class MarketEmptyState extends StatelessWidget {
  final String title;
  final String? message;

  const MarketEmptyState({super.key, required this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(
            SvgIcons.market_icon,
            width: 96.w,
            color: AppColors.textPlaceholder,
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 12.h),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sliver form of [MarketEmptyState] — the store tabs are `CustomScrollView`s,
/// and it takes whatever height is left under the category row so the message
/// sits centred rather than clinging to the header.
class MarketEmptySliver extends StatelessWidget {
  final String title;
  final String? message;

  const MarketEmptySliver({super.key, required this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: MarketEmptyState(title: title, message: message)),
    );
  }
}
