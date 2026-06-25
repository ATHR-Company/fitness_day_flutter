import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/features/shared/widgets/app_drawer.dart';
import 'package:fitness_day/features/shared/widgets/app_header.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/language_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),
      body: Builder(
        builder: (context) {
          return Container(
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
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AppHeader(
                      title: 'profile.title'.tr(),
                      onMenuPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
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
                                SvgIcons.emptyProfile,
                                width: 60.w,
                                height: 60.h,
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
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierColor: AppColors.scrimOverlay.withValues(alpha: 0.5),
                              builder: (context) => const EditProfileDialog(),
                            );
                          },
                        ),
                        _buildMenuItem(
                          title: 'profile.language'.tr(),
                          svgPath: SvgIcons.lang,
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierColor: AppColors.scrimOverlay.withValues(alpha: 0.5),
                              builder: (context) => const LanguageDialog(),
                            );
                          },
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
          );
        }
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
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFAFDFA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10.r), // Based on image: Radius 10px
          border: Border.all(
            color: const Color(0xFFF2F2F2),
            width: 0.2.w, // Based on image: 0.2px
          ),
          boxShadow: AppShadows.profileItemShadow,
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
                  style: TextStyleManager.heading3,
                ),
              ],
            ),
            
            // Right Side in RTL (Left Side visually)
            Icon(
              Icons.arrow_forward_ios, // <
              color: AppColors.primary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
