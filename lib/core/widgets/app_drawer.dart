import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/app_routes.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    int selectedIndex = -1;
    if (location == AppRoutes.home) selectedIndex = 0;
    else if (location == AppRoutes.visits) selectedIndex = 2;
    else if (location == AppRoutes.notifications) selectedIndex = 4;
    else if (location == AppRoutes.profile) selectedIndex = 5;

    return Drawer(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(30.r), // Wait, in RTL the drawer is on the right. If it's an endDrawer it's on the left.
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            // Close Button
            Align(
              alignment: Alignment.centerLeft, // Top left in the image
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(SvgIcons.cross, height: 16.h,),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
            
            // Logo
            SvgPicture.asset(
              SvgIcons.logo,
              height: 100.h,
            ),
            
            SizedBox(height: 32.h),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  _buildMenuItem(
                    index: 0,
                    svgPath: SvgIcons.home,
                    title: 'drawer.home'.tr(),
                    isSelected: selectedIndex == 0,
                    onTap: () {
                      context.push(AppRoutes.home);
                    },
                  ),
                  _buildMenuItem(
                    index: 1,
                    svgPath: SvgIcons.tasks,
                    title: 'drawer.today_tasks'.tr(),
                    isSelected: selectedIndex == 1,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    index: 2,
                    svgPath: SvgIcons.visitsHistory,
                    title: 'drawer.visits_log'.tr(),
                    isSelected: selectedIndex == 2,
                    onTap: () {
                      context.push(AppRoutes.visits);
                    },
                  ),
                  _buildMenuItem(
                    index: 3,
                    svgPath: SvgIcons.clients,
                    title: 'drawer.clients'.tr(),
                    isSelected: selectedIndex == 3,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    index: 4,
                    svgPath: SvgIcons.notification,
                    title: 'drawer.notifications'.tr(),
                    isSelected: selectedIndex == 4,
                    onTap: () {
                      context.push(AppRoutes.notifications);
                    },
                  ),
                  _buildMenuItem(
                    index: 5,
                    svgPath: SvgIcons.person,
                    title: 'drawer.my_profile'.tr(),
                    isSelected: selectedIndex == 5,
                    onTap: () {
                      context.push(AppRoutes.profile);
                    },
                  ),
                  _buildMenuItem(
                    index: 6,
                    svgPath: SvgIcons.logout,
                    title: 'drawer.logout'.tr(),
                    isSelected: false,
                    isLogout: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required String svgPath,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    Color bgColor = AppColors.textSecondary.withValues(alpha: 0.05); // Greyish background
    Color textColor = AppColors.textSecondary;
    Color iconColor = AppColors.textSecondary;

    if (isSelected) {
      bgColor = AppColors.primary.withValues(alpha: 0.05); // Light green background
      textColor = AppColors.primary;
      iconColor = AppColors.primary;
    } else if (isLogout) {
      bgColor = AppColors.red.withValues(alpha: 0.05); // Light red background
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
            // First child in RTL goes to the RIGHT (Icon + Text)
            Row(
              children: [
                SvgPicture.asset(
                  svgPath,
                  colorFilter: ColorFilter.mode(
                    iconColor,
                    BlendMode.srcIn,
                  ),
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
            
            // Second child in RTL goes to the LEFT (arrows)
            !isSelected ?Icon(
              Icons.keyboard_double_arrow_left_rounded,
              color: isLogout ? AppColors.red : AppColors.textSecondary.withValues(alpha: 0.5),
              size: 20.sp,
              fontWeight: FontWeight.bold,
            ): SizedBox(),
          ],
        ),
      ),
    );
  }
}
