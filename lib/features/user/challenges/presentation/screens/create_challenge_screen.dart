import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/selection_dialog.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedType;
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              const _CreateChallengeAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.h),
                      const _ImagePicker(),
                      SizedBox(height: 32.h),
                      _SelectionField(
                        label: 'challenges.create_challenge_type'.tr(),
                        hint: 'challenges.create_challenge_type_hint'.tr(),
                        value: _selectedType,
                        onTap: () => _showSelectionPopup(
                          title: 'challenges.create_challenge_type'.tr(),
                          options: [
                            'challenges.create_type_1'.tr(),
                            'challenges.create_type_2'.tr(),
                          ],
                          onSelected: (val) => setState(() => _selectedType = val),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _TextField(
                        label: 'challenges.create_challenge_name'.tr(),
                        hint: 'challenges.create_challenge_name_hint'.tr(),
                        controller: _nameController,
                      ),
                      SizedBox(height: 20.h),
                      _SelectionField(
                        label: 'challenges.create_challenge_category'.tr(),
                        hint: 'challenges.create_challenge_category_hint'.tr(),
                        value: _selectedCategory,
                        onTap: () => _showSelectionPopup(
                          title: 'challenges.create_challenge_category'.tr(),
                          options: [
                            'challenges.create_category_1'.tr(),
                            'challenges.create_category_2'.tr(),
                          ],
                          onSelected: (val) => setState(() => _selectedCategory = val),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _TextField(
                        label: 'challenges.create_start_date'.tr(),
                        hint: 'challenges.create_start_date_hint'.tr(),
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _pickDate(context),
                      ),
                      SizedBox(height: 40.h),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Handle next step
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
                          'challenges.create_btn_next'.tr(),
                          style: TextStyleManager.style13Medium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
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

  void _showSelectionPopup({
    required String title,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    showSelectionDialog(
      context: context,
      title: title,
      options: options,
      initialValue: '',
      onSelected: onSelected,
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() {
        _dateController.text = '${date.year}/${date.month}/${date.day}';
      });
    }
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _CreateChallengeAppBar extends StatelessWidget {
  const _CreateChallengeAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_rounded, size: 20.sp, color: AppColors.black),
          ),
          const Spacer(),
          Text(
            'challenges.create_title'.tr(),
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          const Spacer(),
          SizedBox(width: 50.sp),
        ],
      ),
    );
  }
}

// ─── Image Picker ─────────────────────────────────────────────────────────────

class _ImagePicker extends StatelessWidget {
  const _ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 90.w,
            height: 90.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4EA),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(Icons.image, color: AppColors.primary, size: 32.sp),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, color: AppColors.primary, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                'challenges.create_add_image'.tr(),
                style: TextStyleManager.style9Medium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Text Field ───────────────────────────────────────────────────────────────

class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;

  const _TextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }
}

// ─── Dropdown Field ───────────────────────────────────────────────────────────

class _SelectionField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final VoidCallback onTap;

  const _SelectionField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = value?.isNotEmpty == true ? value! : hint;
    final displayColor = value?.isNotEmpty == true ? AppColors.black : AppColors.borderGrey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleManager.style11Medium.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyleManager.style11Medium.copyWith(
                      color: displayColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.borderGrey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared input decoration ──────────────────────────────────────────────────

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyleManager.style11Medium.copyWith(color: AppColors.borderGrey),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.primary),
    ),
  );
}
