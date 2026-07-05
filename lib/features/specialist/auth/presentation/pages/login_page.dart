import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_phone_field.dart';
import 'package:fitness_day/core/widgets/app_password_field.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_cubit.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      backgroundColor: AppColors.splashBackgroundGradient.colors.first,
      body: LoaderHud(
        isCall: context.watch<AuthCubit>().state is AuthLoading,
        child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashBackgroundGradient,
        ),
        child: SafeArea(
          child: TopCenteredConstrainedBox(
            horizontalPadding: 0,
            child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 60.h),
                  // App Logo from SVG
                  SvgPicture.asset(SvgIcons.logo, height: 120.h),
                  SizedBox(height: 40.h),
                  // Welcome Text
                  Text(
                    'login.welcome_text'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyleManager.heading3,
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
                  SizedBox(height: 24.h),
                  // Password Field
                  AppPasswordField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'login.password_error'.tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 48.h),
                  // Login Button
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        showAppSnackBar(context, text: 'login.success_login'.tr(), isSuccess: true);
                        context.go(SpecialistAppRoutes.home);
                      } else if (state is AuthFailure) {
                        showAppSnackBar(context, text: state.message, isError: true);
                      }
                    },
                    builder: (context, state) {
                      return CustomButton(
                        text: 'login.next_button'.tr(),
                        onPressed: _onLoginPressed,
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          ),
          ),
        ),
      ),
    );
  }
}
