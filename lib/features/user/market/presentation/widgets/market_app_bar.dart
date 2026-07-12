import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';

/// App bar for the market main screen — title, cart button, and drawer menu.
class MarketAppBar extends StatelessWidget {
  final VoidCallback onCartTap;

  const MarketAppBar({super.key, required this.onCartTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'market.market_title'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onCartTap,
                child: _buildIconButton(SvgIcons.market_icon),
              ),
              SizedBox(width: 8.w),
              // Menu
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openEndDrawer(),
                  child: _buildIconButton(SvgIcons.menuIcon),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(String asset) {
    return Container(
      width: 44.w,
      height: 44.w,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: SvgPicture.asset(
        asset,
        colorFilter: const ColorFilter.mode(
          AppColors.textSecondary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
