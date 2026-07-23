import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/fitness_day.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 80.h),

                // Logo
                AppImage(SvgIcons.logo, height: 152.h),

                SizedBox(height: 48.h),

                // Welcome Text
                Text(
                  LocaleKeys.role_selection_welcome_text.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyleManager.heading3,
                ),

                SizedBox(height: 48.h),

                // Continue as User Button
                _buildRoleButton(
                  title: LocaleKeys.role_selection_continue_as_user.tr(),
                  icon: Icon(Icons.person, color: AppColors.white, size: 24.w),
                  color: AppColors.primary,
                  textColor: AppColors.white,
                  onTap: () {
                    RoleNotifier.instance.setRole(AppRole.user);
                    context.push(UserAppRoutes.login);
                  },
                ),

                SizedBox(height: 24.h),

                // Continue as Specialist Button
                _buildRoleButton(
                  title: LocaleKeys.role_selection_continue_as_specialist.tr(),
                  icon: AppImage(SvgIcons.specialist, height: 24.h),
                  color: AppColors.borderGrey,
                  textColor: AppColors.black,
                  onTap: () {
                    RoleNotifier.instance.setRole(AppRole.specialist);
                    context.push(SpecialistAppRoutes.login);
                  },
                ),

                const Spacer(),

                // Agreement Text
                Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.black,
                      ),
                      children: [
                        TextSpan(
                          text: LocaleKeys.role_selection_agreement_text.tr(),
                        ),
                        TextSpan(
                          text: LocaleKeys.role_selection_terms_of_service.tr(),
                          style: TextStyleManager.style11Medium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(text: LocaleKeys.role_selection_and.tr()),
                        TextSpan(
                          text: LocaleKeys.role_selection_privacy_policy.tr(),
                          style: TextStyleManager.style11Medium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: LocaleKeys.role_selection_in_fitness_day.tr(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required Widget icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyleManager.button.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
