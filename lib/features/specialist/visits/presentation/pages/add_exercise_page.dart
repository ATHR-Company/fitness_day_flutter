import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/selection_bottom_sheet.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  String? _selectedExerciseName;

  void _showExerciseNameSheet() {
    final items = [
      'add_exercise.exercise_1'.tr(),
      'add_exercise.exercise_1'.tr() + ' 2',
      'add_exercise.exercise_1'.tr() + ' 3',
      'add_exercise.exercise_1'.tr() + ' 4',
    ];
    showSelectionBottomSheet(
      context: context,
      title: 'add_exercise.exercise_type'.tr(),
      items: items,
      showSearch: true,
      initialSelectedIndex: _selectedExerciseName != null
          ? items.indexOf(_selectedExerciseName!)
          : 0,
      onConfirm: (index) {
        setState(() {
          _selectedExerciseName = items[index];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.visitsBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Back Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppBackHeader(title: 'add_exercise.title'.tr()),
              ),

              SizedBox(height: 32.h),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise Name
                      _buildLabel('add_exercise.exercise_name'.tr()),
                      _buildTextField(
                        hint:
                            _selectedExerciseName ??
                            'add_exercise.exercise_name_hint'.tr(),
                        icon: Icons.chevron_left,
                        onTap: _showExerciseNameSheet,
                        valueColor: _selectedExerciseName != null
                            ? AppColors.black
                            : AppColors.textSecondary.withValues(alpha: 0.5),
                      ),

                      SizedBox(height: 20.h),

                      // Exercise Time
                      _buildLabel('add_exercise.exercise_time'.tr()),
                      _buildTimeField(),

                      SizedBox(height: 20.h),

                      // Number of Sets
                      _buildLabel('add_exercise.number_of_sets'.tr()),
                      _buildSimpleTextField(
                        hint: 'add_exercise.number_of_sets_hint'.tr(),
                      ),

                      SizedBox(height: 20.h),

                      // Rest Duration
                      _buildLabel('add_exercise.rest_duration'.tr()),
                      _buildSimpleTextField(
                        hint: 'add_exercise.rest_duration_hint'.tr(),
                      ),

                      SizedBox(height: 20.h),

                      // Number of Reps
                      _buildLabel('add_exercise.number_of_reps'.tr()),
                      _buildSimpleTextField(
                        hint: 'add_exercise.number_of_reps_hint'.tr(),
                      ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),

              // Add Button
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: CustomButton(
                  text: 'add_exercise.add_button'.tr(),
                  color: AppColors.primary,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyleManager.heading3.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    VoidCallback? onTap,
    Color? valueColor,
  }) {
    return TextFormField(
      readOnly: onTap != null,
      onTap: onTap,
      textAlign: TextAlign.right,
      style: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyleManager.heading3.copyWith(
          color: valueColor ?? AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        fillColor: AppColors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
        suffixIcon: Icon(
          icon,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          size: 24.sp,
        ),
      ),
    );
  }

  Widget _buildSimpleTextField({required String hint}) {
    return TextFormField(
      textAlign: TextAlign.right,
      style: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyleManager.heading3.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        fillColor: AppColors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      textAlign: TextAlign.right,
      style: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: 'add_exercise.exercise_time_hint'.tr(),
        hintStyle: TextStyleManager.heading3.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        fillColor: AppColors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
        suffixIcon: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTint,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.divider.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'add_exercise.am'.tr(),
                        style: TextStyleManager.heading3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ],
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
