import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pinput/pinput.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/errors/failures.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/app_phone_field.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/loader.dart';
import 'package:fitness_day/core/widgets/resend_code_button.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_cubit.dart';

/// Two-step flow: request an OTP for the new phone number, then verify it.
/// Kept as its own dialog (not part of [PersonalProfilePage]'s identifier
/// row) since it is a multi-step, security-sensitive action — same as
/// [ChangePasswordDialog].
class ChangePhoneDialog extends StatefulWidget {
  /// The user's current phone number (with or without the country code),
  /// used to prefill the field.
  final String? initialPhone;

  const ChangePhoneDialog({super.key, this.initialPhone});

  @override
  State<ChangePhoneDialog> createState() => _ChangePhoneDialogState();
}

class _ChangePhoneDialogState extends State<ChangePhoneDialog> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _otpStep = false;
  String _changePhoneToken = '';

  final _resendCountdown = ResendCountdown();

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.initialPhone ?? '';
  }

  @override
  void dispose() {
    _resendCountdown.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _onSendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _requestCode();
  }

  /// Resending is the same request again — there is no separate endpoint, and
  /// the reply carries a fresh token that replaces the spent one.
  Future<void> _onResendCode() async => _requestCode(isResend: true);

  Future<void> _requestCode({bool isResend = false}) async {
    setState(() => _isLoading = true);
    final result = await context
        .read<UserProfileCubit>()
        .requestChangePhoneOtp(_phoneController.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case Success(:final data):
        setState(() {
          _changePhoneToken = data.changePhoneToken;
          _otpStep = true;
          if (isResend) _otpController.clear();
        });
        _resendCountdown.start(kResendCooldownSeconds);
        showAppSnackBar(context, text: data.message, isSuccess: true);
      case FailureResult(:final failure):
        // A refusal for asking too soon is not a failure to report as one — it
        // says how long is left, which the button counts down.
        if (failure is RateLimitFailure) {
          _resendCountdown.start(failure.retryAfterSeconds);
        }
        showAppSnackBar(context, text: failure.message, isError: true);
    }
  }

  Future<void> _onVerify() async {
    setState(() => _isLoading = true);
    final result = await context.read<UserProfileCubit>().verifyChangePhoneOtp(
          changePhoneToken: _changePhoneToken,
          otp: _otpController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case Success(:final data):
        Navigator.of(context).pop();
        showAppSnackBar(context, text: data, isSuccess: true);
      case FailureResult(:final failure):
        showAppSnackBar(context, text: failure.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 44.w,
      height: 44.h,
      textStyle: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2.0),
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.lightGreenBackground, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('profile.change_phone'.tr(), style: TextStyleManager.heading3),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: AppImage(SvgIcons.cross, color: AppColors.primary, width: 20.r, height: 20.r),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                if (!_otpStep) ...[
                  Form(
                    key: _formKey,
                    child: AppPhoneField(
                      controller: _phoneController,
                      hint: 'profile.new_phone_hint'.tr(),
                    ),
                  ),
                ] else ...[
                  Text(
                    'profile.change_phone_otp_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyleManager.style12Regular.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 16.h),
                  Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Pinput(
                      length: 6,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                    ),
                  ),
                  ResendCodeButton(
                    countdown: _resendCountdown,
                    onResend: _onResendCode,
                  ),
                ],
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                      
                        text: _otpStep ? 'profile.verify_code'.tr() : 'profile.send_code'.tr(),
                        onPressed: _otpStep ? _onVerify : _onSendCode,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomOutlinedButton(
                        text: 'profile.cancel'.tr(),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_isLoading)
              Positioned.fill(
                child: AbsorbPointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: const Center(
                      child: ColorLoader(radius: 16, dotRadius: 4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
