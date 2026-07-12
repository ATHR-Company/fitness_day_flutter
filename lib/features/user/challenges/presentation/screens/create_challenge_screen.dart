import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/selection_dialog.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/challenges/presentation/screens/create_challenge_step2_screen.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_app_bar.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_image_picker.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_selection_field.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_text_field.dart';

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

  List<String> get _typeOptions => [
        'challenges.create_type_1'.tr(),
        'challenges.create_type_2'.tr(),
      ];

  List<String> get _categoryOptions => [
        'challenges.create_category_1'.tr(),
        'challenges.create_category_2'.tr(),
        'challenges.create_category_3'.tr(),
        'challenges.create_category_4'.tr(),
      ];

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
              ChallengeAppBar(title: 'challenges.create_title'.tr()),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.h),
                      const ChallengeImagePicker(),
                      SizedBox(height: 32.h),

                      ChallengeSelectionField(
                        label: 'challenges.create_challenge_type'.tr(),
                        hint: 'challenges.create_challenge_type_hint'.tr(),
                        value: _selectedType,
                        onTap: () => _showSelectionPopup(
                          title: 'challenges.create_challenge_type'.tr(),
                          options: _typeOptions,
                          onSelected: (val) => setState(() {
                            _selectedType = val;
                            _selectedCategory = null; // reset on type change
                          }),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      ChallengeTextField(
                        label: 'challenges.create_challenge_name'.tr(),
                        hint: 'challenges.create_challenge_name_hint'.tr(),
                        controller: _nameController,
                      ),
                      SizedBox(height: 20.h),

                      ChallengeSelectionField(
                        label: 'challenges.create_challenge_category'.tr(),
                        hint: 'challenges.create_challenge_category_hint'.tr(),
                        value: _selectedCategory,
                        onTap: () => _showSelectionPopup(
                          title: 'challenges.create_challenge_category'.tr(),
                          options: _categoryOptions,
                          onSelected: (val) => setState(() => _selectedCategory = val),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      ChallengeTextField(
                        label: 'challenges.create_start_date'.tr(),
                        hint: 'challenges.create_start_date_hint'.tr(),
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _pickDate(context),
                      ),
                      SizedBox(height: 40.h),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateChallengeStep2Screen(),
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
