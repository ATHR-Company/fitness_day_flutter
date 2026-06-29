import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
  final List<TextEditingController> _controllers = List.generate(9, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();

  final List<String> _questions = [
    'هل تعاني من مشاكل صحية حالياً؟',
    'هل لديك أى أمراض مزمنة؟',
    'هل تتناول أدوية حالياً؟',
    'هل سبق أن أجريت عمليات جراحية؟',
    'هل أجريت تحاليل طبية مؤخراً؟',
    'هل تم تشخيصك بنقص فيتامينات؟',
    'هل لديك إصابات رياضية سابقة؟',
    'هل تعاني من تساقط في الشعر؟',
    'هل تشعر بالتعب بشكل متكرر؟',
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
        const SnackBar(
          content: Text('يرجى الإجابة على جميع الأسئلة', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      context.go(UserAppRoutes.home);
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
                child: const AppBackHeader(title: 'المشاكل الصحية'),
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
                          text: 'التالي',
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
      crossAxisAlignment: CrossAxisAlignment.end,
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
                  _questions[index],
                  textAlign: TextAlign.right,
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
                        border: Border.all(
                          color: AppColors.primary,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: isYes ? AppColors.white : AppColors.primary,
                          size: 18.sp,
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
                        border: Border.all(
                          color: AppColors.error,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: isNo ? AppColors.white : AppColors.error,
                          size: 18.sp,
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
              hint: 'اكتب هنا',
              controller: _controllers[index],
            ),
          ),
      ],
    );
  }
}
