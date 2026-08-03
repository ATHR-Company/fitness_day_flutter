import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_info_field.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/features/user/auth/domain/entities/profile_validation_key.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_state.dart';
import 'package:fitness_day/features/user/auth/presentation/widgets/profile_validation_errors.dart';

class DietSystemPage extends StatefulWidget {
  const DietSystemPage({super.key});
  @override
  State<DietSystemPage> createState() => _DietSystemPageState();
}

class _DietSystemPageState extends State<DietSystemPage>
    with ProfileValidationErrors<DietSystemPage> {
  @override
  ProfileSetupStep get validationStep => ProfileSetupStep.diet;

  int _selectedDietType = 0; // 0 for Varied, 1 for Vegetarian
  final _dailyMealsController = TextEditingController();
  final _preferredFoodsController = TextEditingController();
  final _dislikedFoodsController = TextEditingController();
  final _foodAllergiesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    for (final c in [
      _dailyMealsController,
      _preferredFoodsController,
      _dislikedFoodsController,
      _foodAllergiesController,
    ]) {
      c.addListener(clearServerError);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<UserSetupCubit>();
      if (cubit.dietType != null) {
        _selectedDietType = cubit.dietType == 'VEGAN' ? 1 : 0;
        setState(() {});
      }
      if (cubit.dailyMeals != null) {
        _dailyMealsController.text = cubit.dailyMeals.toString();
      }
      if (cubit.preferredFoods != null && cubit.preferredFoods!.isNotEmpty) {
        _preferredFoodsController.text = cubit.preferredFoods!;
      }
      if (cubit.dislikedFoods != null && cubit.dislikedFoods!.isNotEmpty) {
        _dislikedFoodsController.text = cubit.dislikedFoods!;
      }
      if (cubit.foodAllergies != null && cubit.foodAllergies!.isNotEmpty) {
        _foodAllergiesController.text = cubit.foodAllergies!;
      }
    });
  }

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
      final dietTypeStr = _selectedDietType == 1 ? 'VEGAN' : 'MIXED';
      final dailyMealsVal = int.tryParse(_dailyMealsController.text) ?? 3;
      
      context.read<UserSetupCubit>().saveDietData(
        dietType: dietTypeStr,
        dailyMeals: dailyMealsVal,
        preferredFoods: _preferredFoodsController.text.trim(),
        dislikedFoods: _dislikedFoodsController.text.trim(),
        foodAllergies: _foodAllergiesController.text.trim(),
      );
      
      context.push(UserAppRoutes.fitnessSystem);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The request is fired from the fitness screen, so a rejected diet field
    // arrives while this screen sits underneath it in the stack.
    return BlocListener<UserSetupCubit, UserSetupState>(
      listener: (context, state) {
        if (state is UserSetupFailure) handleValidationFailure(state);
      },
      child: Scaffold(
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
                child: AppBackHeader(title: 'login.diet_title'.tr()),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                            // 2. Vegetarian Diet Card
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDietType = 1;
                                    });
                                  },
                                  child: Container(
                                    width: 120.w,
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      color: _selectedDietType == 1
                                          ? AppColors.backgroundTint
                                          : AppColors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: _selectedDietType == 1
                                            ? AppColors.primary
                                            : AppColors.divider.withValues(
                                                alpha: 0.5,
                                              ),
                                        width: _selectedDietType == 1
                                            ? 2.0
                                            : 1.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.04,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AppImage(
                                          SvgIcons.vegeterianDiet,
                                          width: 40.w,
                                          height: 40.h,
                                          color: _selectedDietType == 1
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'login.vegetarian_diet'.tr(),
                                  style: TextStyleManager.style13Medium,
                                ),
                              ],
                            ),
                            // 1. Varied Diet Card
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDietType = 0;
                                    });
                                  },
                                  child: Container(
                                    width: 120.w,
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      color: _selectedDietType == 0
                                          ? AppColors.backgroundTint
                                          : AppColors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: _selectedDietType == 0
                                            ? AppColors.primary
                                            : AppColors.divider.withValues(
                                                alpha: 0.5,
                                              ),
                                        width: _selectedDietType == 0
                                            ? 2.0
                                            : 1.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.04,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AppImage(
                                          SvgIcons.varyDiet,
                                          width: 40.w,
                                          height: 40.h,
                                          color: _selectedDietType == 0
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'login.varied_diet'.tr(),
                                  style: TextStyleManager.style13Medium,
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Server-side error for the diet type choice — there
                        // is no input to hang it on, so it goes under the cards.
                        if (errorFor(ProfileValidationKey.dietType) != null)
                          Padding(
                            key: fieldKey(ProfileValidationKey.dietType),
                            padding: EdgeInsets.only(top: 12.h),
                            child: Text(
                              errorFor(ProfileValidationKey.dietType)!,
                              textAlign: TextAlign.center,
                              style: TextStyleManager.style10Medium
                                  .copyWith(color: AppColors.error),
                            ),
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
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.dailyMeals),
                          errorText: errorFor(ProfileValidationKey.dailyMeals),
                          hint: 'login.daily_meals_hint'.tr(),
                          controller: _dailyMealsController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'auth_val_err_diet_meals'.tr();
                            }
                            final n = int.tryParse(value.trim());
                            if (n == null || n < 1) {
                              return 'auth_val_err_diet_meals_min'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        // 2. Preferred Foods
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.preferredFoods),
                          errorText: errorFor(ProfileValidationKey.preferredFoods),
                          hint: 'login.preferred_foods_hint'.tr(),
                          controller: _preferredFoodsController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth_val_err_diet_foods'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        // 3. Disliked Foods
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.dislikedFoods),
                          errorText: errorFor(ProfileValidationKey.dislikedFoods),
                          hint: 'login.disliked_foods_hint'.tr(),
                          controller: _dislikedFoodsController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth_val_err_diet_disliked'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        // 4. Food Allergies
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.foodAllergies),
                          errorText: errorFor(ProfileValidationKey.foodAllergies),
                          hint: 'login.food_allergies_hint'.tr(),
                          controller: _foodAllergiesController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth_val_err_diet_allergy'.tr();
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
        ),
      ),
      ),
    );
  }
}
