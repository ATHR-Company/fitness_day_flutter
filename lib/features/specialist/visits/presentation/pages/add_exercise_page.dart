import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/selection_bottom_sheet.dart';
import 'package:fitness_day/core/widgets/app_text_field.dart';

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
                      AppFieldLabel(text: 'add_exercise.exercise_name'.tr()),
                      AppTextField(
                        hintText:
                            _selectedExerciseName ??
                            'add_exercise.exercise_name_hint'.tr(),
                        suffixIcon: Icon(
                          Directionality.of(context) == ui.TextDirection.rtl
                              ? Icons.chevron_left
                              : Icons.chevron_right,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          size: 24.sp,
                        ),
                        onTap: _showExerciseNameSheet,
                        valueColor: _selectedExerciseName != null
                            ? AppColors.black
                            : AppColors.textSecondary.withValues(alpha: 0.5),
                      ),

                      SizedBox(height: 20.h),

                      // Exercise Time
                      AppFieldLabel(text: 'add_exercise.exercise_time'.tr()),
                      _buildTimeField(),

                      SizedBox(height: 20.h),

                      // Number of Sets
                      AppFieldLabel(text: 'add_exercise.number_of_sets'.tr()),
                      AppTextField(
                        hintText: 'add_exercise.number_of_sets_hint'.tr(),
                        keyboardType: TextInputType.number,
                      ),

                      SizedBox(height: 20.h),

                      // Rest Duration
                      AppFieldLabel(text: 'add_exercise.rest_duration'.tr()),
                      AppTextField(
                        hintText: 'add_exercise.rest_duration_hint'.tr(),
                      ),

                      SizedBox(height: 20.h),

                      // Number of Reps
                      AppFieldLabel(text: 'add_exercise.number_of_reps'.tr()),
                      AppTextField(
                        hintText: 'add_exercise.number_of_reps_hint'.tr(),
                        keyboardType: TextInputType.number,
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

  Widget _buildTimeField() {
    return AppTextField(
      hintText: 'add_exercise.exercise_time_hint'.tr(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                      style: TextStyleManager.style10Medium.copyWith(
                        color: AppColors.primary,
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
    );
  }
}
