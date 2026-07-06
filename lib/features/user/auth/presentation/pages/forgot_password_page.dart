import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/widgets/app_phone_field.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_auth_cubit.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_auth_state.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSendPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<UserAuthCubit>().sendForgotPasswordOtp(
        _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserAuthCubit, UserAuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSendOtpSuccess) {
            context.push(
              UserAppRoutes.otpVerification,
              extra: {
                'phoneNumber': _phoneController.text.trim(),
                'resetToken': state.response.resetToken,
                'isForgotPassword': true,
              },
            );
          } else if (state is UserAuthFailure) {
            showAppSnackBar(context, text: state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is UserAuthLoading;
          return LoaderHud(
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
                        child: AppBackHeader(title: 'login.forgot_password_title'.tr()),
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
                                    'login.forgot_password_subtitle'.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyleManager.style12Regular.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 60.h),
                                // Phone number field
                                AppPhoneField(
                                  controller: _phoneController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'login.phone_error'.tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 48.h),
                                // Send button
                                CustomButton(
                                  text: 'login.send'.tr(),
                                  onPressed: _onSendPressed,
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
          );
        },
      ),
    );
  }
}
