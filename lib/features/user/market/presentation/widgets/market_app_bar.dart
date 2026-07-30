import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/orders_icon_button.dart';

/// The title stays centred on the screen, so the three buttons have to stay
/// narrow enough not to reach it. At 38 they clear the centred title; going
/// back up to 44 makes the last button sit on top of it.
final double _kIconSize = 38.w;
final double _kIconGap = 6.w;

/// App bar for the market main screen — title, cart, drawer menu, favourites,
/// plus the orders button on the opposite edge.
class MarketAppBar extends StatelessWidget {
  final VoidCallback onCartTap;
  final VoidCallback? onFavoritesTap;

  /// Opens "My Orders". Sits alone on the leading edge, away from the cluster
  /// of the other three, so the centred title stays clear of both sides.
  final VoidCallback? onOrdersTap;

  const MarketAppBar({
    super.key,
    required this.onCartTap,
    this.onFavoritesTap,
    this.onOrdersTap,
  });

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
          if (onOrdersTap != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              // Raw design pixels — the button applies `.w` itself.
              child: OrdersIconButton(onTap: onOrdersTap!, size: 38),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BlocBuilder<CartCubit, CartState>(
                bloc: getIt<CartCubit>(),
                builder: (context, state) {
                  final count = state.badgeCount;
                  return GestureDetector(
                    onTap: onCartTap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildIconButton(
                          child: AppImage(
                            SvgIcons.market_icon,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            top: -2.h,
                            right: -2.w,
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16.w,
                                minHeight: 16.w,
                              ),
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                textAlign: TextAlign.center,
                                style: TextStyleManager.style9Medium.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8.sp,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(width: _kIconGap),
              // Favourites
              GestureDetector(
                onTap: onFavoritesTap,
                child: _buildIconButton(
                  child: Icon(
                    Icons.favorite,
                    color: AppColors.textSecondary,
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: _kIconGap),
              // Menu
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openEndDrawer(),
                  child: _buildIconButton(
                    child: AppImage(
                      SvgIcons.menuIcon,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required Widget child, Color? background}) {
    return Container(
      width: _kIconSize,
      height: _kIconSize,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: background ?? AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(child: child),
    );
  }
}
