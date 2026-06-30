import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/features/shared/widgets/logout_dialog.dart';

class UserAppDrawer extends StatelessWidget {
  final bool isSubscribed;

  const UserAppDrawer({super.key, this.isSubscribed = true});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    // Determine selected index based on subscription state
    int selectedIndex = -1;
    if (isSubscribed) {
      if (location == UserAppRoutes.home) {
        selectedIndex = 0;
      } else if (location == UserAppRoutes.visitLog) selectedIndex = 1;
      else if (location == UserAppRoutes.dietPlan) selectedIndex = 2;
      else if (location == UserAppRoutes.workoutPlan) selectedIndex = 3;
      else if (location == UserAppRoutes.store) selectedIndex = 4;
      else if (location == UserAppRoutes.notifications) selectedIndex = 5;
      else if (location == UserAppRoutes.profile) selectedIndex = 6;
    } else {
      if (location == UserAppRoutes.home) {
        selectedIndex = 0;
      } else if (location == UserAppRoutes.visitLog) selectedIndex = 1;
      else if (location == UserAppRoutes.store) selectedIndex = 2;
      else if (location == UserAppRoutes.profile) selectedIndex = 3;
      else if (location == UserAppRoutes.shareWithFriends) selectedIndex = 4;
    }

    return Drawer(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30.r)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16.h),

            // Close Button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(SvgIcons.cross, height: 16.h),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),

            // Logo
            SvgPicture.asset(SvgIcons.logo, height: 100.h),
            SizedBox(height: 32.h),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: isSubscribed
                    ? _subscribedItems(context, selectedIndex)
                    : _unsubscribedItems(context, selectedIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Subscribed menu ─────────────────────────────────────────────────────────
  List<Widget> _subscribedItems(BuildContext context, int selected) => [
        _buildMenuItem(
          svgPath: SvgIcons.home,
          title: 'drawer.home'.tr(),
          isSelected: selected == 0,
          onTap: () {
            Navigator.pop(context);
            context.go(UserAppRoutes.home);
          },
        ),
        _buildMenuItem(
          svgPath: SvgIcons.visitsHistory,
          title: 'drawer.visit_log'.tr(),
          isSelected: selected == 1,
          onTap: () {
            Navigator.pop(context);
            context.push(UserAppRoutes.visitLog);
          },
        ),
        _buildMenuItem(
          svgPath: SvgIcons.diet,
          title: 'drawer.diet_plan'.tr(),
          isSelected: selected == 2,
          onTap: () {
            Navigator.pop(context);
            context.push(UserAppRoutes.dietPlan);
          },
        ),
        _buildMenuItem(
          svgPath: SvgIcons.workout,
          title: 'drawer.workout_plan'.tr(),
          isSelected: selected == 3,
          onTap: () {
            Navigator.pop(context);
            context.push(UserAppRoutes.workoutPlan);
          },
        ),
        _buildMenuItem(
          svgPath: SvgIcons.barcode,
          title: 'drawer.store'.tr(),
          isSelected: selected == 4,
          onTap: () {
            Navigator.pop(context);
            context.push(UserAppRoutes.store);
          },
        ),
        _buildMenuItem(
          svgPath: SvgIcons.notification,
          title: 'drawer.notifications_alerts'.tr(),
          isSelected: selected == 5,
          onTap: () {
            Navigator.pop(context);
            context.push(UserAppRoutes.notifications);
          },
        ),
        _buildMenuItem(
          svgPath: SvgIcons.person,
          title: 'drawer.my_profile'.tr(),
          isSelected: selected == 6,
          onTap: () {
            Navigator.pop(context);
            context.push(UserAppRoutes.profile);
          },
        ),
        _logoutItem(context),
      ];

  // ── Unsubscribed menu ───────────────────────────────────────────────────────
  List<Widget> _unsubscribedItems(BuildContext context, int selected) => [
        _buildMenuItem(
          svgPath: SvgIcons.home,
          title: 'drawer.home'.tr(),
          isSelected: selected == 0,
          onTap: () {
            Navigator.pop(context);
            context.go(UserAppRoutes.home);
          },
        ),
        _buildMenuItem(
          svgPath: SvgIcons.visitsHistory,
          title: 'drawer.visit_log'.tr(),
          isSelected: selected == 1,
          onTap: () {
            Navigator.pop(context);
            context.push(UserAppRoutes.visitLog);
          },
        ),
        _buildMenuItem(
          svgPath: SvgIcons.barcode,
          title: 'drawer.store'.tr(),
          isSelected: selected == 2,
          onTap: () {
            Navigator.pop(context);
            context.push(UserAppRoutes.store);
          },
        ),
        _buildMenuItem(
          svgPath: SvgIcons.person,
          title: 'drawer.my_profile'.tr(),
          isSelected: selected == 3,
          onTap: () {
            Navigator.pop(context);
            context.push(UserAppRoutes.profile);
          },
        ),
        _buildMenuItem(
          svgPath: SvgIcons.share,
          title: 'drawer.share_with_friends'.tr(),
          isSelected: selected == 4,
          onTap: () {
            Navigator.pop(context);
            context.push(UserAppRoutes.shareWithFriends);
          },
        ),
        _logoutItem(context),
      ];

  Widget _logoutItem(BuildContext context) => _buildMenuItem(
        svgPath: SvgIcons.logout,
        title: 'drawer.logout'.tr(),
        isSelected: false,
        isLogout: true,
        onTap: () {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (_) => const LogoutDialog(),
          );
        },
      );

  // ── Item builder ────────────────────────────────────────────────────────────
  Widget _buildMenuItem({
    required String svgPath,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    Color bgColor = AppColors.textSecondary.withValues(alpha: 0.05);
    Color textColor = AppColors.textSecondary;
    Color iconColor = AppColors.textSecondary;

    if (isSelected) {
      bgColor = AppColors.primary.withValues(alpha: 0.05);
      textColor = AppColors.primary;
      iconColor = AppColors.primary;
    } else if (isLogout) {
      bgColor = AppColors.red.withValues(alpha: 0.05);
      textColor = AppColors.red;
      iconColor = AppColors.red;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  svgPath,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: 20.sp,
                  height: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyleManager.heading3.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (!isSelected)
              Icon(
                Icons.keyboard_double_arrow_left_rounded,
                color: isLogout
                    ? AppColors.red
                    : AppColors.textSecondary.withValues(alpha: 0.5),
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
