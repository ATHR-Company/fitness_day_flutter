import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/features/shared/widgets/custom_button.dart';
import 'package:fitness_day/features/shared/widgets/app_back_header.dart';
import 'package:fitness_day/features/shared/widgets/app_info_field.dart';

class HealthProblemsPage extends StatefulWidget {
  const HealthProblemsPage({super.key});

  @override
  State<HealthProblemsPage> createState() => _HealthProblemsPageState();
}

class _HealthProblemsPageState extends State<HealthProblemsPage> {
  final List<bool?> _answers = List.filled(9, null);
  final List<TextEditingController> _controllers = List.generate(
    9,
    (_) => TextEditingController(),
  );
  final _formKey = GlobalKey<FormState>();

  final List<String> _questions = [
    'auth_health_q1',
    'auth_health_q2',
    'auth_health_q3',
    'auth_health_q4',
    'auth_health_q5',
    'auth_health_q6',
    'auth_health_q7',
    'auth_health_q8',
    'auth_health_q9',
  ];

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onNextPressed() {
    if (_answers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'auth_health_validation_err'.tr(),
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      context.push(UserAppRoutes.bmiReport);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: AppBackHeader(title: 'auth_health_problems_title'.tr()),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.h),
                        Image.asset(
                          AppImages.healthProblems,
                          width: 140.w,
                          height: 140.w,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 32.h),
                        ...List.generate(_questions.length, (index) {
                          return _buildQuestionItem(index);
                        }),
                        SizedBox(height: 32.h),
                        CustomButton(
                          text: 'auth_next_button'.tr(),
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
    );
  }

  Widget _buildQuestionItem(int index) {
    final bool? answer = _answers[index];
    final bool isYes = answer == true;
    final bool isNo = answer == false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          margin: EdgeInsets.only(bottom: isYes ? 8.h : 16.h),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isYes ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _questions[index].tr(),
                  textAlign: TextAlign.start,
                  style: TextStyleManager.style11Medium,
                ),
              ),
              SizedBox(width: 8.w),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _answers[index] = true;
                      });
                    },
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isYes ? AppColors.primary : AppColors.white,
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          SvgIcons.trueIcon,
                          width: 14.w,
                          height: 14.w,
                          colorFilter: ColorFilter.mode(
                            isYes ? AppColors.white : AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _answers[index] = false;
                      });
                    },
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isNo ? AppColors.error : AppColors.white,
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          SvgIcons.falseIcon,
                          width: 12.w,
                          height: 12.w,
                          colorFilter: ColorFilter.mode(
                            isNo ? AppColors.white : AppColors.error,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isYes)
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: AppInfoField(
              hint: 'auth_health_more_details'.tr(),
              controller: _controllers[index],
            ),
          ),
      ],
    );
  }
}
