import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
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

  const HomeHeader({
    super.key,
    this.isSubscribed = true,
    this.userName = '',
    this.userAvatar = '',
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
