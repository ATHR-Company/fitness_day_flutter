import 'package:fitness_day/core/utils/measurement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/core/widgets/app_info_field.dart';
import 'package:fitness_day/core/widgets/selection_dialog.dart';
import 'package:fitness_day/features/user/auth/domain/entities/profile_validation_key.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_state.dart';
import 'package:fitness_day/features/user/auth/presentation/widgets/height_picker_dialog.dart';
import 'package:fitness_day/features/user/auth/presentation/widgets/profile_validation_errors.dart';
import 'package:fitness_day/features/user/auth/presentation/widgets/weight_picker_dialog.dart';
import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';
import 'package:fitness_day/core/utils/no_script_input_formatter.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage>
    with ProfileValidationErrors<UserInfoPage> {
  @override
  ProfileSetupStep get validationStep => ProfileSetupStep.personalInfo;

  final _fullNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _activityController = TextEditingController();
  final _goalController = TextEditingController();
  final _branchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// The picked birth date itself. The controller only ever holds a *display*
  /// string, and that string is localized — re-parsing it was locale-dependent
  /// and silently fell back to a hardcoded 1998-05-15 whenever the parse
  /// failed. Keeping the DateTime removes the round-trip entirely.
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    // Any edit clears the server-side message pinned under a field.
    for (final c in [
      _fullNameController,
      _genderController,
      _birthDateController,
      _heightController,
      _weightController,
      _activityController,
      _goalController,
      _branchController,
    ]) {
      c.addListener(clearServerError);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<UserSetupCubit>();
      if (cubit.goals.isEmpty || cubit.activityLevels.isEmpty || cubit.branches.isEmpty) {
        cubit.fetchLookups();
      }
      // Restore previously entered data
      if (cubit.fullName != null && cubit.fullName!.isNotEmpty) {
        _fullNameController.text = cubit.fullName!;
      }
      if (cubit.height != null) {
        _heightController.text =
            Measurement.withUnit(cubit.height!, 'auth_height_unit'.tr());
      }
      if (cubit.weight != null) {
        _weightController.text =
            Measurement.withUnit(cubit.weight!, 'auth_weight_unit'.tr());
      }
      if (cubit.gender != null && cubit.gender!.isNotEmpty) {
        _genderController.text = cubit.gender == 'female'
            ? 'auth_gender_female'.tr()
            : 'auth_gender_male'.tr();
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _genderController.dispose();
    _birthDateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _activityController.dispose();
    _goalController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final cubit = context.read<UserSetupCubit>();
      
      final selectedGoalName = _goalController.text;
      final selectedActivityName = _activityController.text;
      final selectedBranchName = _branchController.text;
      
      final goalItem = cubit.goals.firstWhere(
        (e) => e.name == selectedGoalName,
        orElse: () => cubit.goals.isNotEmpty ? cubit.goals.first : const LookupItem(id: '6a411c3b54870ff442172d77', name: '', type: '', order: 0),
      );
      
      final activityItem = cubit.activityLevels.firstWhere(
        (e) => e.name == selectedActivityName,
        orElse: () => cubit.activityLevels.isNotEmpty ? cubit.activityLevels.first : const LookupItem(id: '6a411c3b54870ff442172d73', name: '', type: '', order: 0),
      );
      
      final branchItem = cubit.branches.firstWhere(
        (e) => e.name == selectedBranchName,
        orElse: () => cubit.branches.isNotEmpty ? cubit.branches.first : const LookupItem(id: '6a411c3b54870ff442172d7b', name: '', type: '', order: 0),
      );

      // Round on the way out: the pickers can only produce sane values, but a
      // restored controller can carry whatever the server last sent back.
      final double htVal = Measurement.round(
        Measurement.parse(_heightController.text) ?? 170.0,
      );
      final double wtVal = Measurement.round(
        Measurement.parse(_weightController.text) ?? 70.0,
      );

      final genderVal = (_genderController.text == 'auth_gender_female'.tr() || _genderController.text == 'Female' || _genderController.text == 'أنثى')
          ? 'female'
          : 'male';

      // The form validator already blocks an empty birth-date field, so
      // _birthDate is set by the time we get here.
      final birthDateIso = _birthDate!.toUtc().toIso8601String();

      cubit.savePersonalData(
        fullName: _fullNameController.text.trim(),
        gender: genderVal,
        birthDate: birthDateIso,
        height: htVal,
        weight: wtVal,
        activityLevelId: activityItem.id,
        goalId: goalItem.id,
        branchId: branchItem.id,
      );

      context.push(UserAppRoutes.dietSystem);
    }
  }

  void _showSelectionPopup({
    required String title,
    required List<String> options,
    required TextEditingController controller,
  }) {
    showSelectionDialog(
      context: context,
      title: title,
      options: options,
      initialValue: controller.text,
      onSelected: (selected) {
        setState(() {
          controller.text = selected;
        });
      },
    );
  }

  void _showGenderPicker() {
    _showSelectionPopup(
      title: 'auth_user_info_gender'.tr(),
      options: ['auth_gender_male'.tr(), 'auth_gender_female'.tr()],
      controller: _genderController,
    );
  }

  /// `yyyy / MM / dd` rendered in the app's language — not the device's.
  String _formatBirthDate(DateTime date) =>
      DateFormat('yyyy / MM / dd', context.locale.languageCode).format(date);

  Future<void> _showDatePicker() async {
    // Open on the date already chosen rather than always on year 2000.
    var initialDate = _birthDate ?? DateTime(2000);

    // Clamp to valid range just in case.
    final now = DateTime.now();
    if (initialDate.isAfter(now)) initialDate = now;
    if (initialDate.isBefore(DateTime(1940))) initialDate = DateTime(2000);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: now,
      // Without this the calendar takes its month names and numerals from
      // whatever Localizations happens to resolve to, which is why it stayed
      // Arabic while the rest of the app was in English.
      locale: context.locale,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _birthDate = picked;
      _birthDateController.text = _formatBirthDate(picked);
    }
  }

  void _showHeightPicker() {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        // A restored value can carry decimals ("155.1 سم"), which int.tryParse
        // rejected outright and silently reset the wheel to 170.
        final currentVal =
            Measurement.parse(_heightController.text)?.round() ?? 170;
        return HeightPickerDialog(initialHeight: currentVal);
      },
    ).then((val) {
      if (val != null) {
        setState(() {
          _heightController.text =
              Measurement.withUnit(val as num, 'auth_height_unit'.tr());
        });
      }
    });
  }

  void _showWeightPicker() {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        final currentVal = Measurement.parse(_weightController.text) ?? 70.0;
        return WeightPickerDialog(initialWeight: currentVal);
      },
    ).then((val) {
      if (val != null) {
        setState(() {
          _weightController.text =
              Measurement.withUnit(val as num, 'auth_weight_unit'.tr());
        });
      }
    });
  }

  void _showActivityPicker() {
    final cubit = context.read<UserSetupCubit>();
    final options = cubit.activityLevels.map((e) => e.name).toList();
    _showSelectionPopup(
      title: 'auth_activity_level'.tr(),
      options: options,
      controller: _activityController,
    );
  }

  void _showGoalPicker() {
    final cubit = context.read<UserSetupCubit>();
    final options = cubit.goals.map((e) => e.name).toList();
    _showSelectionPopup(
      title: 'auth_goal'.tr(),
      options: options,
      controller: _goalController,
    );
  }

  void _showBranchPicker() {
    final cubit = context.read<UserSetupCubit>();
    final options = cubit.branches.map((e) => e.name).toList();
    _showSelectionPopup(
      title: 'auth_val_err_fitness_place'.tr(),
      options: options,
      controller: _branchController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserSetupCubit, UserSetupState>(
      listener: (context, state) {
        // The submit happens on the last onboarding screen, but a rejected
        // field of *this* screen has to light up here.
        if (state is UserSetupFailure) handleValidationFailure(state);
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
            bottom: false,
            child: TopCenteredConstrainedBox(
              horizontalPadding: 0,
              child: Column(
                children: [
                  Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: AppBackHeader(title: 'login.user_info_title'.tr(), canBack: false,),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //SizedBox(height: 12.h),
                        // Subtitle
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'login.user_info_subtitle'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyleManager.style12Regular.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // 1. Full Name
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.fullName),
                          errorText: errorFor(ProfileValidationKey.fullName),
                          focusNode: fieldFocusNode(ProfileValidationKey.fullName),
                          hint: 'login.full_name_hint'.tr(),
                          iconPath: SvgIcons.person,
                          controller: _fullNameController,
                          inputFormatters: [
                            NameInputFormatter(),
                            LengthLimitingTextInputFormatter(30),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth_val_err_full_name'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10.h),

                        // 2. Gender
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.gender),
                          errorText: errorFor(ProfileValidationKey.gender),
                          focusNode: fieldFocusNode(ProfileValidationKey.gender),
                          hint: 'login.gender_hint'.tr(),
                          iconPath: SvgIcons.gender,
                          controller: _genderController,
                          trailing: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 24.sp,
                          ),
                          onTap: _showGenderPicker,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth_val_err_gender'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10.h),

                        // 3. Birth Date
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.birthDate),
                          errorText: errorFor(ProfileValidationKey.birthDate),
                          focusNode: fieldFocusNode(ProfileValidationKey.birthDate),
                          hint: 'login.birth_date_hint'.tr(),
                          iconPath: SvgIcons.birthDate,
                          controller: _birthDateController,
                          onTap: _showDatePicker,
                          // Validate the DateTime, not the display text — that
                          // is what _onNextPressed actually submits.
                          validator: (_) =>
                              _birthDate == null ? 'auth_val_err_age'.tr() : null,
                        ),
                        SizedBox(height: 10.h),

                        // 4. Height
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.height),
                          errorText: errorFor(ProfileValidationKey.height),
                          focusNode: fieldFocusNode(ProfileValidationKey.height),
                          hint: 'login.height_hint'.tr(),
                          iconPath: SvgIcons.height,
                          controller: _heightController,
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.textSecondary,
                            size: 16.sp,
                          ),
                          onTap: _showHeightPicker,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth_val_err_height'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10.h),

                        // 5. Weight
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.weight),
                          errorText: errorFor(ProfileValidationKey.weight),
                          focusNode: fieldFocusNode(ProfileValidationKey.weight),
                          hint: 'login.weight_hint'.tr(),
                          iconPath: SvgIcons.weight,
                          controller: _weightController,
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.textSecondary,
                            size: 16.sp,
                          ),
                          onTap: _showWeightPicker,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth_val_err_weight'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10.h),

                        // 6. Activity level
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.activityLevel),
                          errorText: errorFor(ProfileValidationKey.activityLevel),
                          focusNode: fieldFocusNode(ProfileValidationKey.activityLevel),
                          hint: 'login.activity_hint'.tr(),
                          iconPath: SvgIcons.activity,
                          controller: _activityController,
                          trailing: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 24.sp,
                          ),
                          onTap: _showActivityPicker,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth_val_err_activity'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10.h),

                        // 7. Goal
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.goal),
                          errorText: errorFor(ProfileValidationKey.goal),
                          focusNode: fieldFocusNode(ProfileValidationKey.goal),
                          hint: 'login.goal_hint'.tr(),
                          iconPath: SvgIcons.goal,
                          controller: _goalController,
                          trailing: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 24.sp,
                          ),
                          onTap: _showGoalPicker,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth_val_err_goal'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10.h),

                        // 8. Nearest branch
                        AppInfoField(
                          key: fieldKey(ProfileValidationKey.branch),
                          errorText: errorFor(ProfileValidationKey.branch),
                          focusNode: fieldFocusNode(ProfileValidationKey.branch),
                          hint: 'login.branch_hint'.tr(),
                          iconPath: SvgIcons.location,
                          controller: _branchController,
                          trailing: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 24.sp,
                          ),
                          onTap: _showBranchPicker,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth_val_err_fitness_place'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32.h),

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
