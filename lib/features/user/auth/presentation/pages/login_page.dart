import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/routes/shared/shared_routes.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/network/device_type_helper.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_auth_cubit.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_auth_state.dart';
import 'package:fitness_day/features/user/auth/data/models/user_login_models.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';
import 'package:fitness_day/core/network/google_sign_in_helper.dart';
import 'package:fitness_day/core/widgets/errors/show_app_error.dart';
import 'package:fitness_day/core/utils/validators.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<UserAuthCubit>().signin(
        UserSigninRequest(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          fcmToken: '',
          deviceType: DeviceTypeHelper.current,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<UserAuthCubit, UserAuthState>(
        listener: (context, state) {
          if (state is UserVerifyOtpSuccess) {
            if (state.response.type == 'user') {
              if (!state.response.isPersonalDataComplete || !state.response.isSurveyComplete) {
                context.read<UserSetupCubit>().fetchLookups();
              }
              if (!state.response.isPersonalDataComplete) {
                context.pushReplacement(UserAppRoutes.userInfo);
              } else if (!state.response.isSurveyComplete) {
                context.pushReplacement(UserAppRoutes.healthProblems);
              } else {
                context.pushReplacement(UserAppRoutes.home);
              }
            } else {
              context.pushReplacement(SpecialistAppRoutes.home);
            }
          } else if (state is UserSigninSuccess) {
            if (state.response.type == 'user') {
              if (!state.response.isPersonalDataComplete || !state.response.isSurveyComplete) {
                context.read<UserSetupCubit>().fetchLookups();
              }
              if (!state.response.isPersonalDataComplete) {
                context.pushReplacement(UserAppRoutes.userInfo);
              } else if (!state.response.isSurveyComplete) {
                context.pushReplacement(UserAppRoutes.healthProblems);
              } else {
                context.pushReplacement(UserAppRoutes.home);
              }
            } else {
              context.pushReplacement(SpecialistAppRoutes.home);
            }
          } else if (state is UserAuthFailure) {
            showAppError(context, state.error, message: state.message);
          }
        },
        child: BlocBuilder<UserAuthCubit, UserAuthState>(
          builder: (context, userAuthState) {
            final isUserLoading = userAuthState is UserAuthLoading;
            return LoaderHud(
              isCall: isUserLoading,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.splashBackgroundGradient,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // ── Back button ──────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                        child: SizedBox(
                          height: 48.h,
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: IconButton(
                              onPressed: () => context.go(SharedRoutes.roleSelection),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minHeight: 48.h,
                                minWidth: 48.w,
                              ),
                              icon: Icon(
                                Icons.chevron_left,
                                color: AppColors.textPrimary,
                                size: 32.sp,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Scrollable form area ─────────────────────────────
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: IntrinsicHeight(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 16.h),

                                        // App Logo
                                        AppImage(SvgIcons.logo, height: 130.h),

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
                                          focusNode: _phoneFocusNode,
                                          textInputAction: TextInputAction.next,
                                          onFieldSubmitted: (_) {
                                            _passwordFocusNode.requestFocus();
                                          },
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
                                          focusNode: _passwordFocusNode,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) => _onLoginPressed(),
                                          validator: AppValidators.loginPassword,
                                        ),

                                        SizedBox(height: 16.h),

                                        // Forgot Password
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                _passwordController.clear();
                                                context.push(
                                                    UserAppRoutes.forgotPassword);
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                LocaleKeys.login_forgot_password.tr(),
                                                style: TextStyleManager
                                                    .style13Medium
                                                    .copyWith(
                                                  color: AppColors.black,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 20.h),

                                        // Login Button
                                        CustomButton(
                                          text: LocaleKeys.login_login_button.tr(),
                                          onPressed: _onLoginPressed,
                                        ),

                                        SizedBox(height: 10.h),

                                        // ── "أو" Divider ─────────────────────────────
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Divider(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.3),
                                                thickness: 1,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w),
                                              child: Text(
                                                LocaleKeys.login_or.tr(),
                                                style: TextStyleManager
                                                    .style14Medium
                                                    .copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.3),
                                                thickness: 1,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 10.h),

                                        // ── Social Buttons ────────────────────────────
                                        Row(
                                          children: [
                                            if (defaultTargetPlatform ==
                                                TargetPlatform.iOS) ...[
                                              Expanded(
                                                child: AppSocialButton(
                                                  label: LocaleKeys.login_apple.tr(),
                                                  icon: AppImage(
                                                    SvgIcons.appleLogin,
                                                    height: 22.h,
                                                  ),
                                                  onTap: () {
                                                    context
                                                        .read<UserAuthCubit>()
                                                        .socialAuth(
                                                          provider: 'APPLE',
                                                          idToken:
                                                              'test_apple_id_token',
                                                        );
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: 16.w),
                                            ],
                                            Expanded(
                                              child: AppSocialButton(
                                                label: LocaleKeys.login_google.tr(),
                                                icon: AppImage(SvgIcons.google,
                                                    height: 22.h),
                                                onTap: () async {
                                                  try {
                                                    final idToken =
                                                        await GoogleSignInHelper
                                                            .signIn();
                                                    if (idToken != null) {
                                                      if (mounted) {
                                                        context
                                                            .read<UserAuthCubit>()
                                                            .socialAuth(
                                                              provider: 'GOOGLE',
                                                              idToken: idToken,
                                                            );
                                                      }
                                                    }
                                                  } on GoogleSignInFailure catch (e) {
                                                    if (mounted) {
                                                      showAppSnackBar(context,
                                                          text: e.message,
                                                          isError: true);
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 24.h),

                                        // ── Sign Up Prompt ────────────────────────────
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 24.h,
                                            top: 12.h,
                                          ),
                                          child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              style: TextStyleManager
                                                  .style14Medium
                                                  .copyWith(
                                                color: AppColors.black,
                                              ),
                                              children: [
                                                TextSpan(
                                                    text: LocaleKeys
                                                        .login_no_account
                                                        .tr()),
                                                WidgetSpan(
                                                  alignment:
                                                      PlaceholderAlignment
                                                          .middle,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _passwordController.clear();
                                                      context.push(
                                                          UserAppRoutes.signUp);
                                                    },
                                                    child: Text(
                                                      LocaleKeys
                                                          .login_create_account
                                                          .tr(),
                                                      style: TextStyleManager
                                                          .style14Bold
                                                          .copyWith(
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
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
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
