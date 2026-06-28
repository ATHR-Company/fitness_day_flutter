import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/features/shared/widgets/custom_button.dart';

class FitnessSystemPage extends StatefulWidget {
  const FitnessSystemPage({super.key});

  @override
  State<FitnessSystemPage> createState() => _FitnessSystemPageState();
}

class _FitnessSystemPageState extends State<FitnessSystemPage> {
  final _weeklyExercisesController = TextEditingController();
  final _dailyStepsController = TextEditingController();
  final _preferredExercisesController = TextEditingController();
  final _dailyExerciseHoursController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _weeklyExercisesController.dispose();
    _dailyStepsController.dispose();
    _preferredExercisesController.dispose();
    _dailyExerciseHoursController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.go(UserAppRoutes.home);
    }
  }



  @override
  Widget build(BuildContext context) {
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
              // Header Back Button Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Directionality.of(context) == ui.TextDirection.rtl
                            ? Icons.arrow_forward_ios
                            : Icons.arrow_back_ios,
                        color: AppColors.black,
                        size: 22.sp,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.h),
                        // Title
                        Text(
                          'login.fitness_title'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyleManager.heading2.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Subtitle
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'login.fitness_subtitle'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyleManager.style12Regular.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(height: 48.h),

                        // 1. Weekly Exercises
                        _InfoField(
                          hint: 'login.weekly_exercises_hint'.tr(),
                          iconPath: SvgIcons.workout,
                          controller: _weeklyExercisesController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال عدد مرات الرياضة أسبوعياً';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),

                        // 2. Daily Steps
                        _InfoField(
                          hint: 'login.daily_steps_hint'.tr(),
                          iconPath: SvgIcons.activity,
                          controller: _dailyStepsController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال عدد خطواتك اليومية';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),

                        // 3. Preferred Exercises
                        _InfoField(
                          hint: 'login.preferred_exercises_hint'.tr(),
                          iconPath: SvgIcons.goal,
                          controller: _preferredExercisesController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال تمارينك المفضلة';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),

                        // 4. Daily Exercise Hours
                        _InfoField(
                          hint: 'login.daily_exercise_hours_hint'.tr(),
                          iconPath: SvgIcons.clock,
                          controller: _dailyExerciseHoursController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال عدد ساعات التمارين';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 64.h),

                        // Next Button
                        CustomButton(
                          text: 'login.next'.tr(),
                          onPressed: _onNextPressed,
                        ),
                        SizedBox(height: 32.h),
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

// ── Reusable Info Field Widget ──────────────────────────────────────────────
class _InfoField extends StatelessWidget {
  final String hint;
  final String iconPath;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  const _InfoField({
    required this.hint,
    required this.iconPath,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType ?? TextInputType.text,
      textAlign: TextAlign.right,
      style: TextStyleManager.heading3.copyWith(
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyleManager.heading3.copyWith(
          color: AppColors.textSecondary,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15.h),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1.0),
        ),
      ),
    );
  }
}
