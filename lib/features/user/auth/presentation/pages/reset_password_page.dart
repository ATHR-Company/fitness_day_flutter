import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_password_field.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_auth_cubit.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_auth_state.dart';
import 'package:fitness_day/core/widgets/errors/show_app_error.dart';
import 'package:fitness_day/core/utils/validators.dart';

class ResetPasswordPage extends StatefulWidget {
  final String resetToken;
  const ResetPasswordPage({super.key, required this.resetToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<UserAuthCubit>().resetPassword(
        widget.resetToken,
        _passwordController.text,
        _confirmPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserAuthCubit, UserAuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordResetSuccess) {
            showAppSnackBar(context, text: state.response.message, isSuccess: true);
            context.go(UserAppRoutes.login);
          } else if (state is UserAuthFailure) {
            showAppError(context, state.error, message: state.message);
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
                bottom: false,
                child: TopCenteredConstrainedBox(
                  horizontalPadding: 0,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: AppBackHeader(title: 'login.reset_password_title'.tr()),
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
                                    'login.reset_password_subtitle'.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyleManager.style12Regular.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 48.h),
                                // Password Field
                                AppPasswordField(
                                  controller: _passwordController,
                                  validator: AppValidators.password,
                                ),
                                SizedBox(height: 24.h),
                                // Confirm Password Field
                                AppPasswordField(
                                  controller: _confirmPasswordController,
                                  hint: 'login.confirm_password_hint'.tr(),
                                  validator: (value) =>
                                      AppValidators.confirmPassword(
                                    value,
                                    _passwordController.text,
                                  ),
                                ),
                                SizedBox(height: 48.h),
                                // Next Button
                                CustomButton(
                                  text: 'login.next'.tr(),
                                  onPressed: _onNextPressed,
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
