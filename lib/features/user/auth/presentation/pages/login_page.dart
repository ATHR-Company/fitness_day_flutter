import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/widgets/app_phone_field.dart';
import 'package:fitness_day/core/widgets/app_password_field.dart';
import 'package:fitness_day/core/widgets/app_social_button.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_cubit.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_state.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_auth_cubit.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_auth_state.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';
import 'package:fitness_day/core/network/google_sign_in_helper.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        _phoneController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserAuthCubit, UserAuthState>(
        listener: (context, state) {
          if (state is UserVerifyOtpSuccess) {
            context.read<UserSetupCubit>().fetchLookups();
            if (!state.response.isPersonalDataComplete) {
              context.pushReplacement(UserAppRoutes.userInfo);
            } else if (!state.response.isSurveyComplete) {
              context.pushReplacement(UserAppRoutes.healthProblems);
            } else {
              context.pushReplacement(UserAppRoutes.home);
            }
          } else if (state is UserAuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<UserAuthCubit, UserAuthState>(
          builder: (context, userAuthState) {
            final isUserLoading = userAuthState is UserAuthLoading;
            return LoaderHud(
              isCall: context.watch<AuthCubit>().state is AuthLoading || isUserLoading,
              child: Container(
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
                  SizedBox(height: 40.h),

                  // App Logo
                  SvgPicture.asset(SvgIcons.logo, height: 130.h),

                  SizedBox(height: 40.h),

                  // Welcome Text
                  Text(
                    LocaleKeys.login_welcome_text.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyleManager.heading3,
                  ),

                  SizedBox(height: 40.h),

                  // Phone Field
                  AppPhoneField(
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return LocaleKeys.login_phone_hint.tr();
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
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.push(UserAppRoutes.forgotPassword);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          LocaleKeys.login_forgot_password.tr(),
                          style: TextStyleManager.style13Medium.copyWith(
                            color: AppColors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Login Button
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(LocaleKeys.login_success_login.tr()),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        context.go(UserAppRoutes.home);
                      } else if (state is AuthFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return CustomButton(
                        text: LocaleKeys.login_login_button.tr(),
                        onPressed: _onLoginPressed,
                      );
                    },
                  ),

                  SizedBox(height: 10.h),

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

                  SizedBox(height: 10.h),

                  // ── Social Buttons ─────────────────────────────────────────
                  Row(
                    children: [
                      // Apple Button
                      Expanded(
                        child: AppSocialButton(
                          label: LocaleKeys.login_apple.tr(),
                          icon: SvgPicture.asset(
                            SvgIcons.appleLogin,
                            height: 22.h,
                          ),
                          onTap: () {
                            context.read<UserAuthCubit>().socialAuth(
                              provider: 'APPLE',
                              idToken: 'test_apple_id_token',
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: AppSocialButton(
                          label: LocaleKeys.login_google.tr(),
                          icon: SvgPicture.asset(SvgIcons.google, height: 22.h),
                          onTap: () async {
                            try {
                              final idToken = await GoogleSignInHelper.signIn();
                              if (idToken != null) {
                                if (mounted) {
                                  context.read<UserAuthCubit>().socialAuth(
                                    provider: 'GOOGLE',
                                    idToken: idToken,
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('خطأ أثناء تسجيل الدخول بجوجل: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // ── Sign Up Prompt ─────────────────────────────────────────
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyleManager.style14Medium.copyWith(
                        color: AppColors.black,
                      ),
                      children: [
                        TextSpan(text: LocaleKeys.login_no_account.tr()),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              context.push(UserAppRoutes.signUp);
                            },
                            child: Text(
                              LocaleKeys.login_create_account.tr(),
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
            )));
          },
        ),
      ),
    );
  }
}
