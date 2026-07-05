import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
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

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onVerifyPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.isForgotPassword) {
        _showSuccessBottomSheet(
          context,
          isPersonalDataComplete: false,
          isSurveyComplete: false,
          message: 'login.verify_success_title'.tr(),
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
                          context.pushReplacement(UserAppRoutes.resetPassword);
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
                child: SvgPicture.asset(SvgIcons.decor, height: 180.h),
              ),
              // Overflow checkmark badge
              Positioned(
                top: -45.r,
                child: SvgPicture.asset(SvgIcons.success, height: 90.h),
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
          context.read<UserSetupCubit>().fetchLookups();
          _showSuccessBottomSheet(
            context,
            isPersonalDataComplete: state.response.isPersonalDataComplete,
            isSurveyComplete: state.response.isSurveyComplete,
            message: state.response.message,
          );
        } else if (state is UserAuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is UserAuthLoading;
        return Scaffold(
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
                                  textDirection: ui.TextDirection.ltr, // Keep pin numbers LTR ordered
                                  child: Pinput(
                                    length: 6,
                                    controller: _pinController,
                                    keyboardType: TextInputType.number,
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
                                        return ''; // simple invisible invalid state or standard text
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: 48.h),
                                // Send Button
                                CustomButton(
                                  text: 'login.send'.tr(),
                                  onPressed: _onVerifyPressed,
                                ),
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
