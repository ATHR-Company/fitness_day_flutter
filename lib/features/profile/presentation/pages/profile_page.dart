import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashBackgroundGradient, // Similar to the light green gradient
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              
              // Custom Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 40.w), // Spacer for centering
                    Text(
                      'profile.title'.tr(),
                      style: TextStyleManager.heading2.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    // Menu Button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Builder(
                        builder: (context) {
                          return IconButton(
                            icon: Icon(Icons.menu, color: AppColors.textSecondary),
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Avatar Section
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            SvgIcons.profile,
                            width: 60.w,
                            height: 60.h,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8.h,
                        left: 8.w, // Bottom left
                        child: Container(
                          width: 16.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'conversations.dummy_name'.tr(), // Resuing "محمد عبدالله"
                    style: TextStyleManager.heading2.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Menu Items List
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  children: [
                    _buildMenuItem(
                      title: 'profile.personal_profile'.tr(),
                      svgPath: SvgIcons.profile,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      title: 'profile.edit_password'.tr(),
                      svgPath: SvgIcons.editPassword,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      title: 'profile.language'.tr(),
                      svgPath: SvgIcons.lang,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      title: 'profile.about_us'.tr(),
                      svgPath: SvgIcons.aboutUs,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      title: 'profile.terms_conditions'.tr(),
                      svgPath: SvgIcons.conditions,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      title: 'profile.privacy_policy'.tr(),
                      svgPath: SvgIcons.privacy,
                      onTap: () {},
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String svgPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Side in RTL (Right Side visually)
            Row(
              children: [
                SvgPicture.asset(
                  svgPath,
                  width: 40.sp,
                  height: 40.sp,
                ),
                SizedBox(width: 16.w),
                Text(
                  title,
                  style: TextStyleManager.heading3.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            // Right Side in RTL (Left Side visually)
            Icon(
              Icons.arrow_back_ios, // <
              color: AppColors.primary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
