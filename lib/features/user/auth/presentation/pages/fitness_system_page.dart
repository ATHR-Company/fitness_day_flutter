import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_info_field.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/auth/domain/entities/profile_validation_key.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_state.dart';
import 'package:fitness_day/features/user/auth/presentation/widgets/profile_validation_errors.dart';
import 'package:fitness_day/core/widgets/errors/show_app_error.dart';

class FitnessSystemPage extends StatefulWidget {
  const FitnessSystemPage({super.key});
  @override
  State<FitnessSystemPage> createState() => _FitnessSystemPageState();
}

class _FitnessSystemPageState extends State<FitnessSystemPage>
    with ProfileValidationErrors<FitnessSystemPage> {
  @override
  ProfileSetupStep get validationStep => ProfileSetupStep.fitness;

  final _weeklyExercisesController = TextEditingController();
  final _dailyStepsController = TextEditingController();
  final _preferredExercisesController = TextEditingController();
  final _dailyExerciseHoursController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    for (final c in [
      _weeklyExercisesController,
      _dailyStepsController,
      _preferredExercisesController,
      _dailyExerciseHoursController,
    ]) {
      c.addListener(clearServerError);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<UserSetupCubit>();
      if (cubit.weeklyWorkouts != null) {
        _weeklyExercisesController.text = cubit.weeklyWorkouts.toString();
      }
      if (cubit.dailySteps != null) {
        _dailyStepsController.text = cubit.dailySteps.toString();
      }
      if (cubit.preferredExercises != null && cubit.preferredExercises!.isNotEmpty) {
        _preferredExercisesController.text = cubit.preferredExercises!;
      }
      if (cubit.dailyWorkoutHours != null) {
        _dailyExerciseHoursController.text = cubit.dailyWorkoutHours.toString();
      }
    });
  }

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
      final weeklyWorkoutsVal = int.tryParse(_weeklyExercisesController.text) ?? 3;
      final dailyStepsVal = int.tryParse(_dailyStepsController.text) ?? 8000;
      final dailyWorkoutHoursVal = double.tryParse(_dailyExerciseHoursController.text) ?? 1.0;

      context.read<UserSetupCubit>().saveFitnessData(
        weeklyWorkouts: weeklyWorkoutsVal,
        dailySteps: dailyStepsVal,
        preferredExercises: _preferredExercisesController.text.trim(),
        dailyWorkoutHours: dailyWorkoutHoursVal,
      );

      context.read<UserSetupCubit>().submitPersonalData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserSetupCubit, UserSetupState>(
      listener: (context, state) {
        if (state is CompletePersonalDataSuccess) {
          showAppSnackBar(context, text: state.message, isSuccess: true);
          context.push(UserAppRoutes.healthProblems);
        } else if (state is UserSetupFailure) {
          // Field-level error on this screen → pin it under the input.
          if (handleValidationFailure(state)) return;

          // Field-level error from an earlier screen → walk back to it; that
          // screen picks the same failure up and shows it under its own field.
          final step = state.fieldKey?.step;
          if (step != null && step != ProfileSetupStep.fitness) {
            final int steps = step == ProfileSetupStep.diet ? 1 : 2;
            for (int i = 0; i < steps && context.canPop(); i++) {
              context.pop();
            }
            return;
          }

          // Anything else (network, server, unknown key) stays a snack bar.
          showAppError(context, state.error, message: state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is UserSetupLoading;
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
                    child: AppBackHeader(title: 'login.fitness_title'.tr()),
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
                            AppInfoField(
                              key: fieldKey(ProfileValidationKey.weeklyWorkouts),
                              errorText:
                                  errorFor(ProfileValidationKey.weeklyWorkouts),
                              hint: 'login.weekly_exercises_hint'.tr(),
                              controller: _weeklyExercisesController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'auth_val_err_fitness_days'.tr();
                                }
                                final n = int.tryParse(value.trim());
                                if (n == null || n < 1) {
                                  return 'auth_val_err_fitness_days_min'.tr();
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            // 2. Daily Steps
                            AppInfoField(
                              key: fieldKey(ProfileValidationKey.dailySteps),
                              errorText:
                                  errorFor(ProfileValidationKey.dailySteps),
                              hint: 'login.daily_steps_hint'.tr(),
                              controller: _dailyStepsController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'auth_val_err_fitness_steps'.tr();
                                }
                                final n = int.tryParse(value.trim());
                                if (n == null || n < 1) {
                                  return 'auth_val_err_fitness_steps_min'.tr();
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            // 3. Preferred Exercises
                            AppInfoField(
                              key: fieldKey(
                                  ProfileValidationKey.preferredExercises),
                              errorText: errorFor(
                                  ProfileValidationKey.preferredExercises),
                              hint: 'login.preferred_exercises_hint'.tr(),
                              controller: _preferredExercisesController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'auth_val_err_fitness_tool'.tr();
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            // 4. Daily Exercise Hours
                            AppInfoField(
                              key: fieldKey(
                                  ProfileValidationKey.dailyWorkoutHours),
                              errorText: errorFor(
                                  ProfileValidationKey.dailyWorkoutHours),
                              hint: 'login.daily_exercise_hours_hint'.tr(),
                              controller: _dailyExerciseHoursController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'auth_val_err_fitness_time'.tr();
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
            ),
          ),
        );
      },
    );
  }
}
