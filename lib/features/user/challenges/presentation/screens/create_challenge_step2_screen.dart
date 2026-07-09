import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/core/widgets/selection_dialog.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_created_dialog.dart';

class CreateChallengeStep2Screen extends StatefulWidget {
  const CreateChallengeStep2Screen({super.key});

  @override
  State<CreateChallengeStep2Screen> createState() =>
      _CreateChallengeStep2ScreenState();
}

class _CreateChallengeStep2ScreenState
    extends State<CreateChallengeStep2Screen> {
  String? _selectedExercise;
  final _setsController = TextEditingController();
  final _restController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _exerciseOptions = [
    'تمرين الضغط',
    'تمرين القرفصاء',
    'تمرين البطن',
    'تمرين الظهر',
    'الجري في المكان',
  ];

  @override
  void dispose() {
    _setsController.dispose();
    _restController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ──────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 20.sp,
                        color: AppColors.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'إنشاء تحدي',
                      style: TextStyleManager.heading2.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(width: 20.sp),
                  ],
                ),
              ),

              // ── Form ────────────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 24.h),

                      // اسم التمرين
                      _buildLabel('اسم التمرين'),
                      SizedBox(height: 8.h),
                      _buildExerciseField(),
                      SizedBox(height: 20.h),

                      // عدد المجموعات
                      _buildLabel('عدد المجموعات'),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _setsController,
                        hint: 'ادخل عدد التمرين',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20.h),

                      // مدة الاستراحة
                      _buildLabel('مدة الاستراحة بين المجموعات'),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _restController,
                        hint: 'ادخل مدة الاستراحة',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20.h),

                      // وصف التحدي
                      _buildLabel('وصف  التحدي'),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _descriptionController,
                        hint: 'ادخل وصف التحدي',
                        maxLines: 5,
                      ),

                      SizedBox(height: 40.h),

                      // ── Create Button ────────────────────────────────────
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => ChallengeCreatedDialog(
                              onStart: () {
                                // Pop the dialog
                                Navigator.of(context).pop();
                                // Pop step2 + step1 → back to ChallengesScreen
                                Navigator.of(context)
                                  ..pop()
                                  ..pop();
                              },
                              onShare: () {
                                // Handle sharing if needed
                                // Pop the dialog
                                Navigator.of(context).pop();
                                // Pop step2 + step1 → back to ChallengesScreen
                                Navigator.of(context)
                                  ..pop()
                                  ..pop();
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: Size(double.infinity, 54.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'إنشاء',
                          style: TextStyleManager.style13Medium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
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

  // ── Exercise Selection Field ─────────────────────────────────────────────
  Widget _buildExerciseField() {
    final hasValue = _selectedExercise != null && _selectedExercise!.isNotEmpty;
    return GestureDetector(
      onTap: () {
        showSelectionDialog(
          context: context,
          title: 'اسم التمرين',
          options: _exerciseOptions,
          initialValue: _selectedExercise ?? '',
          onSelected: (val) => setState(() => _selectedExercise = val),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.borderGrey.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? _selectedExercise! : 'ابحث عن اسم التمرين',
                style: TextStyleManager.style11Medium.copyWith(
                  color: hasValue ? AppColors.textPrimary : AppColors.borderGrey,
                ),
                textDirection:ui.TextDirection.rtl,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.borderGrey,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: TextStyleManager.style11Medium.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyleManager.style11Medium.copyWith(
          color: AppColors.borderGrey,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.borderGrey.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.borderGrey.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
