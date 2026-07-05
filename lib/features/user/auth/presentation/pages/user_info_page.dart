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
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/core/widgets/app_info_field.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_state.dart';
import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _fullNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _activityController = TextEditingController();
  final _goalController = TextEditingController();
  final _branchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<UserSetupCubit>();
      if (cubit.goals.isEmpty || cubit.activityLevels.isEmpty || cubit.branches.isEmpty) {
        cubit.fetchLookups();
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

      final double htVal = double.tryParse(_heightController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 170.0;
      final double wtVal = double.tryParse(_weightController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 70.0;

      final genderVal = (_genderController.text == 'auth_gender_female'.tr() || _genderController.text == 'Female' || _genderController.text == 'أنثى')
          ? 'female'
          : 'male';

      String birthDateIso = '1998-05-15T00:00:00.000Z';
      try {
        final parsedDate = DateFormat('yyyy / MM / dd').parse(_birthDateController.text);
        birthDateIso = parsedDate.toUtc().toIso8601String();
      } catch (_) {
        // Fallback to ISO string format if already parsed or invalid
      }

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
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: options.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected =
                          option == controller.text ||
                          (controller.text.isEmpty && index == 0);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            controller.text = option;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.backgroundTint
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            option,
                            textAlign: TextAlign.start,
                            style: TextStyleManager.heading3.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.black.withValues(alpha: 0.7),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
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

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
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
      _birthDateController.text = DateFormat('yyyy / MM / dd').format(picked);
    }
  }

  void _showHeightPicker() {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        final currentVal =
            int.tryParse(
              _heightController.text.replaceAll(
                ' ${'auth_height_unit'.tr()}',
                '',
              ),
            ) ??
            170;
        return HeightPickerDialog(initialHeight: currentVal);
      },
    ).then((val) {
      if (val != null) {
        setState(() {
          _heightController.text = '$val ${'auth_height_unit'.tr()}';
        });
      }
    });
  }

  void _showWeightPicker() {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        final currentVal =
            double.tryParse(
              _weightController.text.replaceAll(
                ' ${'auth_weight_unit'.tr()}',
                '',
              ),
            ) ??
            70.0;
        return WeightPickerDialog(initialWeight: currentVal);
      },
    ).then((val) {
      if (val != null) {
        setState(() {
          _weightController.text = '$val ${'auth_weight_unit'.tr()}';
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
    return BlocBuilder<UserSetupCubit, UserSetupState>(
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
                child: AppBackHeader(title: 'login.user_info_title'.tr()),
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
                          hint: 'login.full_name_hint'.tr(),
                          iconPath: SvgIcons.person,
                          controller: _fullNameController,
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
                          hint: 'login.birth_date_hint'.tr(),
                          iconPath: SvgIcons.birthDate,
                          controller: _birthDateController,
                          onTap: _showDatePicker,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth_val_err_age'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10.h),

                        // 4. Height
                        AppInfoField(
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

// ── Custom Height Picker Dialog ─────────────────────────────────────────────
class HeightPickerDialog extends StatefulWidget {
  final int initialHeight;
  const HeightPickerDialog({super.key, required this.initialHeight});

  @override
  State<HeightPickerDialog> createState() => _HeightPickerDialogState();
}

class _HeightPickerDialogState extends State<HeightPickerDialog> {
  late int _selectedHeight;
  late FixedExtentScrollController _scrollController;
  final int minHeight = 50;
  final int maxHeight = 280;

  @override
  void initState() {
    super.initState();
    int initial = widget.initialHeight;
    if (initial < minHeight || initial > maxHeight) {
      initial = 170;
    }
    _selectedHeight = initial;
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedHeight - minHeight,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _animateTo(int val) {
    if (val >= minHeight && val <= maxHeight) {
      setState(() {
        _selectedHeight = val;
      });
      _scrollController.animateToItem(
        val - minHeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'auth_select_height'.tr(),
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              height: 150.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Background Highlight Bar (behind scroll view)
                  Container(
                    height: 50.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTint,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  // 2. Scroll View
                  ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 50.h,
                    physics: const FixedExtentScrollPhysics(),
                    perspective: 0.005,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedHeight = minHeight + index;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: maxHeight - minHeight + 1,
                      builder: (context, index) {
                        final val = minHeight + index;
                        final isSelected = val == _selectedHeight;
                        return Container(
                          height: 50.h,
                          alignment: Alignment.center,
                          child: Text(
                            '$val',
                            style: isSelected
                                ? TextStyleManager.heading2.copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.bold,
                                  )
                                : TextStyleManager.heading3.copyWith(
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  // 3. Left Clickable Arrow (layered on top)
                  Positioned(
                    left: 12.w,
                    child: GestureDetector(
                      onTap: () => _animateTo(_selectedHeight - 1),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Icon(
                          Icons.skip_next,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                  // 4. Right Clickable Arrow (layered on top)
                  Positioned(
                    right: 12.w,
                    child: GestureDetector(
                      onTap: () => _animateTo(_selectedHeight + 1),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Icon(
                          Icons.skip_previous,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.pop(context, _selectedHeight);
                },
                child: Text(
                  'auth_save'.tr(),
                  style: TextStyleManager.style14Bold.copyWith(
                    color: AppColors.white,
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

// ── Custom Weight Picker Dialog ─────────────────────────────────────────────
class WeightPickerDialog extends StatefulWidget {
  final double initialWeight;
  const WeightPickerDialog({super.key, required this.initialWeight});

  @override
  State<WeightPickerDialog> createState() => _WeightPickerDialogState();
}

class _WeightPickerDialogState extends State<WeightPickerDialog> {
  late int _selectedInt;
  late int _selectedDecimal;
  late FixedExtentScrollController _intScrollController;
  late FixedExtentScrollController _decimalScrollController;
  final int minWeight = 1;
  final int maxWeight = 640;

  @override
  void initState() {
    super.initState();
    double w = widget.initialWeight;
    if (w < minWeight || w > maxWeight) {
      w = 70.0;
    }
    _selectedInt = w.toInt();
    _selectedDecimal = ((w - _selectedInt) * 10).round().clamp(0, 9);

    _intScrollController = FixedExtentScrollController(
      initialItem: _selectedInt - minWeight,
    );
    _decimalScrollController = FixedExtentScrollController(
      initialItem: _selectedDecimal,
    );
  }

  @override
  void dispose() {
    _intScrollController.dispose();
    _decimalScrollController.dispose();
    super.dispose();
  }

  void _animateTo(int intVal, int decVal) {
    if (intVal >= minWeight && intVal <= maxWeight) {
      setState(() {
        _selectedInt = intVal;
      });
      _intScrollController.animateToItem(
        intVal - minWeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
    if (decVal >= 0 && decVal <= 9) {
      setState(() {
        _selectedDecimal = decVal;
      });
      _decimalScrollController.animateToItem(
        decVal,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'auth_select_weight'.tr(),
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              height: 150.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Background Highlight Bar (behind scroll views)
                  Container(
                    height: 50.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTint,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  // 2. Scroll Wheels Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50.w,
                        child: ListWheelScrollView.useDelegate(
                          controller: _decimalScrollController,
                          itemExtent: 50.h,
                          physics: const FixedExtentScrollPhysics(),
                          perspective: 0.005,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedDecimal = index;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 10,
                            builder: (context, index) {
                              final val = index;
                              final isSelected = val == _selectedDecimal;
                              return Container(
                                height: 50.h,
                                alignment: Alignment.center,
                                child: Text(
                                  '$val',
                                  style: isSelected
                                      ? TextStyleManager.heading2.copyWith(
                                          color: AppColors.black,
                                          fontWeight: FontWeight.bold,
                                        )
                                      : TextStyleManager.heading3.copyWith(
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.6),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Text(
                        '  .  ',
                        style: TextStyleManager.heading2.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 70.w,
                        child: ListWheelScrollView.useDelegate(
                          controller: _intScrollController,
                          itemExtent: 50.h,
                          physics: const FixedExtentScrollPhysics(),
                          perspective: 0.005,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedInt = minWeight + index;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: maxWeight - minWeight + 1,
                            builder: (context, index) {
                              final val = minWeight + index;
                              final isSelected = val == _selectedInt;
                              return Container(
                                height: 50.h,
                                alignment: Alignment.center,
                                child: Text(
                                  '$val',
                                  style: isSelected
                                      ? TextStyleManager.heading2.copyWith(
                                          color: AppColors.black,
                                          fontWeight: FontWeight.bold,
                                        )
                                      : TextStyleManager.heading3.copyWith(
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.6),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 3. Left Clickable Arrow (layered on top)
                  Positioned(
                    left: 12.w,
                    child: GestureDetector(
                      onTap: () {
                        int newInt = _selectedInt;
                        int newDec = _selectedDecimal - 1;
                        if (newDec < 0) {
                          newDec = 9;
                          newInt--;
                        }
                        _animateTo(newInt, newDec);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Icon(
                          Icons.skip_next,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                  // 4. Right Clickable Arrow (layered on top)
                  Positioned(
                    right: 12.w,
                    child: GestureDetector(
                      onTap: () {
                        int newInt = _selectedInt;
                        int newDec = _selectedDecimal + 1;
                        if (newDec > 9) {
                          newDec = 0;
                          newInt++;
                        }
                        _animateTo(newInt, newDec);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Icon(
                          Icons.skip_previous,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  final finalWeight = _selectedInt + (_selectedDecimal / 10.0);
                  Navigator.pop(context, finalWeight);
                },
                child: Text(
                  'auth_save'.tr(),
                  style: TextStyleManager.style14Bold.copyWith(
                    color: AppColors.white,
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
