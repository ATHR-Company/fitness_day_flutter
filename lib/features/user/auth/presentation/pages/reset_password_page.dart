import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:flutter/material.dart';
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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

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
      // Show success feedback
      showAppSnackBar(context, text: 'login.success_login'.tr(), isSuccess: true);
      context.go(UserAppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoaderHud(
        isCall: false,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'login.password_error'.tr();
                            }
                            if (value.length < 6) {
                              return 'login.password_too_short'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.h),
                        // Confirm Password Field
                        AppPasswordField(
                          controller: _confirmPasswordController,
                          hint: 'login.confirm_password_hint'.tr(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'login.password_error'
                                  .tr(); // reuse same empty check
                            }
                            if (value != _passwordController.text) {
                              return 'login.passwords_dont_match'.tr();
                            }
                            return null;
                          },
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
      ),
    );
  }
}
