import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:fitness_day/features/specialist/profile/presentation/widgets/edit_profile_dialog.dart';
import 'package:fitness_day/core/widgets/profile/language_dialog.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import 'package:fitness_day/features/specialist/profile/presentation/manager/specialist_profile_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:fitness_day/features/specialist/profile/presentation/manager/specialist_profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Same reason as the user profile page: `.tr()` doesn't subscribe a widget
    // to the locale, and this screen hosts the language dialog, so it has to
    // rebuild itself when the language changes.
    context.locale;

    return BlocProvider(
      create: (context) => di.getIt<SpecialistProfileCubit>()..getSpecialistProfile(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          context.go(SpecialistAppRoutes.home);
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          endDrawer: const AppDrawer(),
          body: Builder(
            builder: (context) {
              return SafeArea(
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
  
                    Expanded(
                      child: BlocBuilder<SpecialistProfileCubit, SpecialistProfileState>(
                        builder: (context, state) {
                          final cubit = context.read<SpecialistProfileCubit>();
                          if (state is SpecialistProfileLoading && cubit.profileData == null) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          } else if (state is SpecialistProfileFailure && cubit.profileData == null) {
                            return AppErrorView(
                              error: state.error,
                              message: state.message,
                              onRetry: () => context.read<SpecialistProfileCubit>().getSpecialistProfile(),
                            );
                          } else if (cubit.profileData != null) {
                            final data = cubit.profileData!;
                          return Column(
                              children: [
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
                                            child: AppImage(
                                              data.avatar.isNotEmpty ? data.avatar : SvgIcons.emptyProfile,
                                              width: data.avatar.isNotEmpty ? 100.w : 60.w,
                                              height: data.avatar.isNotEmpty ? 100.h : 60.h,
                                              isAvatar: data.avatar.isEmpty,
                                              radius: data.avatar.isNotEmpty ? 50.r : null,
                                       
                                           fit: data.avatar.isNotEmpty ? BoxFit.cover : BoxFit.contain,
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
                                              border: Border.all(
                                                color: AppColors.white,
                                                width: 3,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      data.name,
                                    
                                      style: TextStyleManager.heading2.copyWith(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                ],
                                ),

                                SizedBox(height: 32.h),
  
                                //  MenuItemsList
                                 
                                
                                    Expanded(
                                      child: ListView(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                                        children: [
                                          _buildMenuItem(
                                            title: 'profile.personal_profile'.tr(),
                                            svgPath: SvgIcons.profile,
                                            onTap: (
                                       ) {
                                              final cubit = context.read<SpecialistProfileCubit>();
                                              showDialog(
                                                context: context,
                                                barrierColor: 
                                            AppColors.scrimOverlay.withValues(
                                                  alpha: 0.5,
                                                
                                              
                                                ),
                                                builder: (_) => BlocProvider.value(
                                                  value: cubit,
                                                  child: const EditProfileDialog(),
                                                ),
                                              );
                                         
                                      },
                                          ),
                                          _buildMenuItem(
                                            title: 'profile.language'.tr(),
                                            svgPath: SvgIcons.lang,
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                barrierColor: AppColors.scrimOverlay.withValues(
                                            alpha: 0.5,
                                                ),
                                                builder: (context) => const LanguageDialog(),
                                              );
                                            },
                                              
                                            
                                    ),      
                                    _buildMenuItem(
                                                 
                                      title: 'profile.about_us'.tr(),
                                      svgPath: SvgIcons.aboutUs,
                                      onTap:       () {},
                                    ),      
                                    _buildMenuItem(
                                                      
                                      title: 'profile.terms_conditions'.tr(),
                                      svgPath: SvgIcons.conditions,
                                      onTap: () {},
                                    ),      
                                                      
                                    _buildMenuItem(
                                                      
                                                      
                                      title: 'profile.privacy_policy'.tr(),
                                      svgPath: SvgIcons.privacy,
                                      onTap:       () {},
                                    ),      
                                    SizedBox(height: 40.h),
                                  ],      
                                ),      
                                                      
                              ),      
                                                      
                                                      
                            ],          
                                                            
                          );          
                        }      
                        return const SizedBox();
                      },      
                    ),      
                  ),      
                ],      
              ),      
            );
          },      
        ),      
      ),      
    ));     
  }      
      
  Widget _buildMenuItem({      
    required String title,      
    required String svgPath,      
    required VoidCallback onTap,      
  }) {      
    return GestureDetector(      
      onTap: onTap,      
      child: Container(      
                                               
                                                    
                                                    
                                               
        margin: EdgeInsets.only(bottom      : 12.h),
        padding: EdgeInsets.symmetric(      horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(      
          gradient: const LinearGradient(
                                                
                                                
            colors: [AppColors.white,       AppColors.dialogBackground],
            begin: Alignment.topCenter      ,
            end: Alignment.bottomCenter,      
          ),      
          borderRadius: BorderRadius.circular(
            10.r,      
                                                     
                                                        
                                                      
          ), // Based on image: Radius 10p      x
          border: Border.all(      
            color: AppColors.dividerLight,
            width: 0.2.w, // Based o      n image: 0.2px
          ),      
          boxShadow: AppShadows.      profileItemShadow,
        ),      
        child: Row(      
          mainAxisAlignment:       MainAxisAlignment.spaceBetween,
          children: [      
            // Left Side   in RTL (Right Side visually)
            Row(  
              children: [
                AppImage(svgPath, width: 40.sp, height: 40.sp),
                  SizedBox(width: 16.w),
                  Text(title, style: TextStyleManager.heading3),
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
