import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/cart_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/routes/user_routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../user/support/presentation/pages/contact_us_page.dart';

class HomeHeader extends StatelessWidget {
  final bool isSubscribed;
  final String userName;
  final String userAvatar;

  /// Shows the store's cart button here on home. Used by the unsubscribed
  /// home, where the packages are bought straight from the page — without it
  /// the buyer has to walk through the store just to reach their own cart.
  final bool showCart;

  const HomeHeader({
    super.key,
    this.isSubscribed = true,
    this.userName = '',
    this.userAvatar = '',
    this.showCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.headerBackground,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // Avatar → profile
          GestureDetector(
            onTap: () => context.push(UserAppRoutes.profile),
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greenSoftTint, width: 2),
                image: DecorationImage(
                  image: NetworkImage(
                    userAvatar.isNotEmpty
                        ? userAvatar
                        : 'https://img.magnific.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?semt=ais_hybrid&w=740&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Greeting + name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'home.welcome_greeting'.tr(),
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userName.isNotEmpty ? userName : 'home.welcome_name'.tr(),
                  style: TextStyleManager.style14Bold.copyWith(
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(width: 16.w),

          // Chat button — only for subscribed users
          if (isSubscribed) ...[
            _IconButton(
              svgPath: SvgIcons.chatIcon,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ContactUsPage(),
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],

          // Cart button — same target as the store's cart icon
          if (showCart) ...[
            const _CartIconButton(),
            SizedBox(width: 8.w),
          ],

          // Menu button
          _IconButton(
            svgPath: SvgIcons.menuIcon,
            onTap: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final String svgPath;
  final VoidCallback? onTap;

  const _IconButton({required this.svgPath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: AppImage(
          svgPath,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Cart button with the same live badge the market app bar carries — both read
/// the singleton [CartCubit], so a package added from home shows up here at
/// once.
class _CartIconButton extends StatelessWidget {
  const _CartIconButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      bloc: getIt<CartCubit>(),
      builder: (context, state) {
        final count = state.badgeCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _IconButton(
              svgPath: SvgIcons.market_icon,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
                // Checking out or emptying the cart changes the badge.
                getIt<CartCubit>().loadCounters();
              },
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
        );
      },
    );
  }
}
