import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/profile/language_dialog.dart';
import 'package:fitness_day/core/widgets/profile/change_password_dialog.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';

import '../../../user_home/presentation/widgets/user_app_drawer.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int _selectedTab = 0; // 0 = Settings, 1 = Fitness Day
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const UserAppDrawer(),
      body: Builder(
        builder: (context) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.splashBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AppHeader(
                      title: 'profile.title'.tr(),
                      onMenuPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // User Info Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: AppShadows.profileItemShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Edit Button

                          // Avatar + Name/Email (RTL Layout)
                          Row(
                            children: [
                              Container(
                                width: 50.r,
                                height: 50.r,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    SvgIcons.person,
                                    width: 28.w,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'رنا محمد',
                                    style: TextStyleManager.style14Bold.copyWith(
                                      color: AppColors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'rana mohamed @ gmail.com',
                                    style: TextStyleManager.style11Medium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              context.push(UserAppRoutes.personalProfile);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 1.5),
                              ),
                              child: Icon(
                                Icons.edit,
                                color: AppColors.primary,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Segmented Tabs
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: AppSegmentedControl(
                      type: AppSegmentedControlType.unified,
                      items: [
                        'drawer.settings'.tr(),
                        'home.specialist_role'.tr(), // "يوم الرشاقة" / Fitness Day
                      ],
                      selectedIndex: _selectedTab,
                      onItemSelected: (index) {
                        setState(() => _selectedTab = index);
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // List of Menu Items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      children: _selectedTab == 0
                          ? _buildSettingsItems(context)
                          : _buildFitnessDayItems(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Settings Tab ───────────────────────────────────────────────────────────
  List<Widget> _buildSettingsItems(BuildContext context) => [
        _buildMenuItem(
          title: 'profile.personal_profile'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.profile),
          onTap: () {
            context.push(UserAppRoutes.personalProfile);
          },
        ),
        _buildMenuItem(
          title: 'profile.edit_password'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.editPassword),
          onTap: () {
            showDialog(
              context: context,
              barrierColor: AppColors.scrimOverlay.withValues(alpha: 0.5),
              builder: (context) => const ChangePasswordDialog(),
            );
          },
        ),
        _buildMenuItem(
          title: 'drawer.notifications_alerts'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.notifications),
          trailing: Switch(
            value: _notificationsEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
            },
          ),
          onTap: () {},
        ),
        _buildMenuItem(
          title: 'profile.language'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.lang),
          onTap: () {
            showDialog(
              context: context,
              barrierColor: AppColors.scrimOverlay.withValues(alpha: 0.5),
              builder: (context) => const LanguageDialog(),
            );
          },
        ),
        _buildMenuItem(
          title: 'profile_page.achievements'.tr(), // "الانجازات"
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.achievements),
          onTap: () {},
        ),
        _buildMenuItem(
          title: 'home.category_progress'.tr(), // "التقدم"
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.progress),
          onTap: () {},
        ),
        _buildMenuItem(
          title: 'profile_page.awards'.tr(), // "الجوائز"
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.rewards),
          onTap: () {},
        ),
        _buildMenuItem(
          title: 'profile_page.delete_account'.tr(), // "حذف الحساب"
          iconWidget: _buildCircleIcon(
            iconPath: SvgIcons.deleteAccount,
            backgroundColor: AppColors.red.withValues(alpha: 0.1),
            iconColor: AppColors.red,
          ),
          onTap: () {
            // Delete account confirmation dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                title: Text('profile_page.delete_account'.tr(), textAlign: TextAlign.right),
                content: Text('profile_page.delete_account_confirm'.tr(), textAlign: TextAlign.right),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('profile.cancel'.tr(), style: const TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('visit_details.delete'.tr(), style: TextStyle(color: AppColors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 24.h),
      ];

  // ── Fitness Day Tab ────────────────────────────────────────────────────────
  List<Widget> _buildFitnessDayItems(BuildContext context) => [
        _buildMenuItem(
          title: 'profile.about_us'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.aboutUs),
          onTap: () {},
        ),
        _buildMenuItem(
          title: 'profile.privacy_policy'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.privacy),
          onTap: () {},
        ),
        _buildMenuItem(
          title: 'profile.terms_conditions'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.conditions),
          onTap: () {},
        ),
        _buildMenuItem(
          title: 'profile_page.rate_app'.tr(), // "قيم التطبيق"
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.review),
          onTap: () {},
        ),
        SizedBox(height: 24.h),
      ];

  // Helper to build circular icon wrapper
  Widget _buildCircleIcon({
    String? iconPath,
    IconData? iconData,
    Color backgroundColor = const Color(0xFFE0F7E9),
    Color iconColor = AppColors.primary,
  }) {
    return Center(
      child: iconPath != null
          ? SvgPicture.asset(
              iconPath,
              width: 40.r,
              height: 40.r,
            )
          : Icon(
              iconData,
              size: 22.sp,
              color: iconColor,
            ),
    );
  }

  // Helper to build menu item row
  Widget _buildMenuItem({
    required String title,
    required Widget iconWidget,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.white, AppColors.dialogBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.dividerLight,
            width: 0.2.w,
          ),
          boxShadow: AppShadows.profileItemShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // Right visual side (Icon + Text)
            Row(
              children: [
                iconWidget,
                SizedBox(width: 16.w),
                Text(title, style: TextStyleManager.heading3),
              ],
            ),

            // Left visual side (trailing or arrow)
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 16.sp,
                ),
          ],
        ),
      ),
    );
  }
}
