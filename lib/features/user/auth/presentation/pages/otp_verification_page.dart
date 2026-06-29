import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/features/shared/widgets/custom_button.dart';
import 'package:fitness_day/features/shared/widgets/app_back_header.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final bool isForgotPassword;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
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
      _showSuccessBottomSheet(context);
    }
  }

  void _showSuccessBottomSheet(BuildContext context) {
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
                      'login.verify_success_title'.tr(),
                      style: TextStyleManager.heading2.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Subtitle
                    Text(
                      'login.verify_success_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyleManager.style12Regular.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 64.h),
                    // Next Button
                    CustomButton(
                      text: 'login.next'.tr(),
                      onPressed: () {
                        Navigator.pop(modalContext);
                        context.pushReplacement(
                          widget.isForgotPassword
                              ? UserAppRoutes.resetPassword
                              : UserAppRoutes.userInfo,
                        );
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
      width: 54.w,
      height: 54.h,
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

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashBackgroundGradient,
        ),
        child: SafeArea(
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
                        // OTP Pinput Fields
                        Directionality(
                          textDirection: ui
                              .TextDirection
                              .ltr, // Keep pin numbers LTR ordered
                          child: Pinput(
                            length: 5,
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
                              if (value == null || value.length < 5) {
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
    );
  }
}
