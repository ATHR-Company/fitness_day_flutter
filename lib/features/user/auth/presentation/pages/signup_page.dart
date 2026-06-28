import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/features/shared/widgets/app_phone_field.dart';
import 'package:fitness_day/features/shared/widgets/app_password_field.dart';
import 'package:fitness_day/features/shared/widgets/custom_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('login.success_login'.tr()),
          backgroundColor: AppColors.success,
        ),
      );
      context.push(
        UserAppRoutes.otpVerification,
        extra: {
          'phoneNumber': _phoneController.text.trim(),
          'isForgotPassword': false,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 60.h),

                  // App Logo
                  SvgPicture.asset(
                    SvgIcons.logo,
                    height: 130.h,
                  ),

                  SizedBox(height: 40.h),

                  // Welcome Text
                  Text(
                    LocaleKeys.login_welcome_text.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.black,
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Phone Field
                  AppPhoneField(
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'login.phone_error'.tr();
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Password Field
                  AppPasswordField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return LocaleKeys.login_password_error.tr();
                      }
                      if (value.length < 6) {
                        return 'login.password_too_short'.tr();
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Confirm Password Field
                  AppPasswordField(
                    controller: _confirmPasswordController,
                    hint: 'login.confirm_password_hint'.tr(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return LocaleKeys.login_password_error.tr();
                      }
                      if (value != _passwordController.text) {
                        return 'login.passwords_dont_match'.tr();
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 32.h),

                  // Sign Up Button
                  CustomButton(
                    text: LocaleKeys.login_create_account.tr(),
                    onPressed: _onSignUpPressed,
                  ),

                  SizedBox(height: 20.h),

                  // ── "أو" Divider ──────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          LocaleKeys.login_or.tr(),
                          style: TextStyleManager.style14Medium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // ── Social Buttons ─────────────────────────────────────────
                  Row(
                    children: [
                      // Apple Button
                      Expanded(
                        child: _SocialButton(
                          label: LocaleKeys.login_apple.tr(),
                          icon: SvgPicture.asset(SvgIcons.appleLogin, height: 22.h),
                          onTap: () {
                            // TODO: Apple Sign-In
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // Google Button
                      Expanded(
                        child: _SocialButton(
                          label: LocaleKeys.login_google.tr(),
                          icon: SvgPicture.asset(SvgIcons.google, height: 22.h),
                          onTap: () {
                            // TODO: Google Sign-In
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // ── Login Prompt ─────────────────────────────────────────
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyleManager.style14Medium.copyWith(
                        color: AppColors.black,
                      ),
                      children: [
                        TextSpan(text: 'login.already_have_account'.tr()),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              context.go(UserAppRoutes.login);
                            },
                            child: Text(
                              'login.login_now'.tr(),
                              style: TextStyleManager.style14Bold.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' !'),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Social Button Widget ───────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: const Color(0xFFDCDBDB),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyleManager.style14Bold.copyWith(
                  color: AppColors.black,
                ),
              ),
              SizedBox(width: 8.w),
              icon,
            ],
          ),
        ),
      ),
    );
  }
}
