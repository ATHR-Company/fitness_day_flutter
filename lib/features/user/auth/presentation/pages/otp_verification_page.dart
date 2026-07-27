import 'dart:ui' as ui;
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_auth_cubit.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_auth_state.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';

import '../manager/user_setup_cubit.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String? signupToken;
  final bool isForgotPassword;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    this.signupToken,
    this.isForgotPassword = false,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _currentResetToken;

  @override
  void initState() {
    super.initState();
    _currentResetToken = widget.signupToken ?? '';
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onVerifyPressed() {
    // Dismiss keyboard first so it doesn't push the layout
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.isForgotPassword) {
        context.read<UserAuthCubit>().verifyForgotPasswordOtp(
          _currentResetToken,
          _pinController.text.trim(),
        );
      } else {
        final request = UserVerifyOtpRequest(
          signupToken: widget.signupToken ?? '',
          otp: _pinController.text.trim(),
        );
        context.read<UserAuthCubit>().verifyOtp(request);
      }
    }
  }

  void _showSuccessBottomSheet(
    BuildContext context, {
    required bool isPersonalDataComplete,
    required bool isSurveyComplete,
    required String message,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (modalContext) {
        return PopScope(
          canPop: false, // Prevent dismissing by back button
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                decoration: BoxDecoration(
                  gradient: AppColors.splashBackgroundGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.r),
                    topRight: Radius.circular(32.r),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 64.h),
                    // Title
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyleManager.heading2.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 64.h),
                    // Next Button
                    CustomButton(
                      text: 'login.next'.tr(),
                      onPressed: () {
                        Navigator.pop(modalContext);
                        if (widget.isForgotPassword) {
                          context.pushReplacement(UserAppRoutes.resetPassword, extra: _currentResetToken);
                        } else {
                          if (!isPersonalDataComplete) {
                            context.pushReplacement(UserAppRoutes.userInfo);
                          } else if (!isSurveyComplete) {
                            context.pushReplacement(UserAppRoutes.healthProblems);
                          } else {
                            context.pushReplacement(UserAppRoutes.home);
                          }
                        }
                      },
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
              // Decor SVG at the bottom left
              Positioned(
                bottom: 0,
                left: 0,
                child: AppImage(SvgIcons.decor, height: 180.h),
              ),
              // Overflow checkmark badge
              Positioned(
                top: -45.r,
                child: AppImage(SvgIcons.success, height: 90.h),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Custom Pinput Theme Config
    final defaultPinTheme = PinTheme(
      width: 48.w,
      height: 48.h,
      textStyle: TextStyleManager.heading2.copyWith(color: AppColors.black),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2.0),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color(0xFFF4FAF5),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
    );

    return BlocConsumer<UserAuthCubit, UserAuthState>(
      listener: (context, state) {
        if (state is UserVerifyOtpSuccess) {
          // Fetch lookups using the new token
          if (!state.response.isPersonalDataComplete || !state.response.isSurveyComplete) {
            context.read<UserSetupCubit>().fetchLookups();
          }
          _showSuccessBottomSheet(
            context,
            isPersonalDataComplete: state.response.isPersonalDataComplete,
            isSurveyComplete: state.response.isSurveyComplete,
            message: state.response.message,
          );
        } else if (state is ForgotPasswordVerifyOtpSuccess) {
          _currentResetToken = state.response.resetToken;
          _showSuccessBottomSheet(
            context,
            isPersonalDataComplete: false,
            isSurveyComplete: false,
            message: state.response.message,
          );
        } else if (state is ForgotPasswordResendOtpSuccess) {
          _currentResetToken = state.response.resetToken;
          showAppSnackBar(context, text: state.response.message, isSuccess: true);
        } else if (state is UserAuthFailure) {
          showAppSnackBar(context, text: state.message, isError: true);
        }
      },
      builder: (context, state) {
        final isLoading = state is UserAuthLoading;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: LoaderHud(
            isCall: isLoading,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.splashBackgroundGradient,
              ),
              child: SafeArea(
                child: TopCenteredConstrainedBox(
                  horizontalPadding: 0,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: AppBackHeader(title: 'login.verify_title'.tr()),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 20.h),
                                SizedBox(height: 16.h),
                                // Subtitle
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Text(
                                    'login.verify_subtitle'.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyleManager.style12Regular.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 48.h),
                                // OTP Pinput Fields (6 digits)
                                Directionality(
                                  textDirection: ui.TextDirection.ltr,
                                  child: Pinput(
                                    length: 6,
                                    controller: _pinController,
                                    keyboardType: TextInputType.number,
                                    scrollPadding: EdgeInsets.zero,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    defaultPinTheme: defaultPinTheme,
                                    focusedPinTheme: focusedPinTheme,
                                    submittedPinTheme: submittedPinTheme,
                                    preFilledWidget: Text(
                                      '-',
                                      style: TextStyleManager.heading2.copyWith(
                                        color: AppColors.textSecondary.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.length < 6) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: 48.h),
                                // Send Button — back in its original place
                                CustomButton(
                                  text: 'login.send'.tr(),
                                  onPressed: _onVerifyPressed,
                                ),
                                if (widget.isForgotPassword) ...[
                                  SizedBox(height: 24.h),
                                  TextButton(
                                    onPressed: () {
                                      context.read<UserAuthCubit>().resendForgotPasswordOtp(_currentResetToken);
                                    },
                                    child: Text(
                                      LocaleKeys.login_resend_code.tr(),
                                      style: TextStyleManager.style14Bold.copyWith(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
