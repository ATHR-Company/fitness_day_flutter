import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/core/widgets/selection_dialog.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_app_bar.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_created_dialog.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_selection_field.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/challenge_text_field.dart';

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

  List<String> get _exerciseOptions => [
        'challenges.exercise_1'.tr(),
        'challenges.exercise_2'.tr(),
        'challenges.exercise_3'.tr(),
        'challenges.exercise_4'.tr(),
        'challenges.exercise_5'.tr(),
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
          bottom: false,
          child: Column(
            children: [
              ChallengeAppBar(title: 'challenges.step2_title'.tr()),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.h),

                      ChallengeSelectionField(
                        label: 'challenges.step2_exercise_label'.tr(),
                        hint: 'challenges.step2_exercise_hint'.tr(),
                        value: _selectedExercise,
                        onTap: () => showSelectionDialog(
                          context: context,
                          title: 'challenges.step2_exercise_label'.tr(),
                          options: _exerciseOptions,
                          initialValue: _selectedExercise ?? '',
                          onSelected: (val) =>
                              setState(() => _selectedExercise = val),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      ChallengeTextField(
                        label: 'challenges.step2_sets_label'.tr(),
                        hint: 'challenges.step2_sets_hint'.tr(),
                        controller: _setsController,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20.h),

                      ChallengeTextField(
                        label: 'challenges.step2_rest_label'.tr(),
                        hint: 'challenges.step2_rest_hint'.tr(),
                        controller: _restController,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20.h),

                      ChallengeTextField(
                        label: 'challenges.step2_desc_label'.tr(),
                        hint: 'challenges.step2_desc_hint'.tr(),
                        controller: _descriptionController,
                        maxLines: 5,
                      ),

                      SizedBox(height: 40.h),

                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => ChallengeCreatedDialog(
                              onStart: () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                  ..pop()
                                  ..pop();
                              },
                              onShare: () {
                                Navigator.of(context).pop();
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
                          'challenges.step2_create_button'.tr(),
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
}
