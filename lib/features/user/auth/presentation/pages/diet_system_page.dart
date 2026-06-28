import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/features/shared/widgets/custom_button.dart';

class DietSystemPage extends StatefulWidget {
  const DietSystemPage({super.key});

  @override
  State<DietSystemPage> createState() => _DietSystemPageState();
}

class _DietSystemPageState extends State<DietSystemPage> {
  int _selectedDietType = 0; // 0 for Varied, 1 for Vegetarian
  final _dailyMealsController = TextEditingController();
  final _preferredFoodsController = TextEditingController();
  final _dislikedFoodsController = TextEditingController();
  final _foodAllergiesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _dailyMealsController.dispose();
    _preferredFoodsController.dispose();
    _dislikedFoodsController.dispose();
    _foodAllergiesController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.push(UserAppRoutes.fitnessSystem);
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
                          'login.diet_title'.tr(),
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
                            'login.diet_subtitle_select'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyleManager.style12Regular.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Diet Cards Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 1. Varied Diet Card
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDietType = 0;
                                });
                              },
                              child: Container(
                                width: 140.w,
                                height: 120.h,
                                decoration: BoxDecoration(
                                  color: _selectedDietType == 0
                                      ? AppColors.backgroundTint
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: _selectedDietType == 0
                                        ? AppColors.primary
                                        : AppColors.divider.withValues(alpha: 0.5),
                                    width: _selectedDietType == 0 ? 2.0 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      SvgIcons.varyDiet,
                                      width: 40.w,
                                      height: 40.h,
                                      colorFilter: ColorFilter.mode(
                                        _selectedDietType == 0
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'login.varied_diet'.tr(),
                                      style: TextStyleManager.style12Regular.copyWith(
                                        color: _selectedDietType == 0
                                            ? AppColors.primary
                                            : AppColors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 2. Vegetarian Diet Card
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDietType = 1;
                                });
                              },
                              child: Container(
                                width: 140.w,
                                height: 120.h,
                                decoration: BoxDecoration(
                                  color: _selectedDietType == 1
                                      ? AppColors.backgroundTint
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: _selectedDietType == 1
                                        ? AppColors.primary
                                        : AppColors.divider.withValues(alpha: 0.5),
                                    width: _selectedDietType == 1 ? 2.0 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      SvgIcons.vegeterianDiet,
                                      width: 40.w,
                                      height: 40.h,
                                      colorFilter: ColorFilter.mode(
                                        _selectedDietType == 1
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'login.vegetarian_diet'.tr(),
                                      style: TextStyleManager.style12Regular.copyWith(
                                        color: _selectedDietType == 1
                                            ? AppColors.primary
                                            : AppColors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 36.h),

                        // Section 2 Title
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'login.diet_subtitle_enter'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyleManager.style12Regular.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // 1. Daily Meals
                        _InfoField(
                          hint: 'login.daily_meals_hint'.tr(),
                          iconPath: SvgIcons.diet,
                          controller: _dailyMealsController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال عدد وجباتك اليومية';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),

                        // 2. Preferred Foods
                        _InfoField(
                          hint: 'login.preferred_foods_hint'.tr(),
                          iconPath: SvgIcons.goal,
                          controller: _preferredFoodsController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال الأطعمة المفضلة';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),

                        // 3. Disliked Foods
                        _InfoField(
                          hint: 'login.disliked_foods_hint'.tr(),
                          iconPath: SvgIcons.cross,
                          controller: _dislikedFoodsController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال الأطعمة غير المفضلة';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),

                        // 4. Food Allergies
                        _InfoField(
                          hint: 'login.food_allergies_hint'.tr(),
                          iconPath: SvgIcons.conditions,
                          controller: _foodAllergiesController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال الحساسية الغذائية';
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
        prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 20.h),
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
