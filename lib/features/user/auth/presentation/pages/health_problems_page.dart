import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_info_field.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_state.dart';
import 'package:fitness_day/features/user/auth/data/models/health_questions_model.dart';
import 'package:fitness_day/features/user/auth/data/models/submit_health_answers_models.dart';

class HealthProblemsPage extends StatefulWidget {
  const HealthProblemsPage({super.key});

  @override
  State<HealthProblemsPage> createState() => _HealthProblemsPageState();
}

class _HealthProblemsPageState extends State<HealthProblemsPage> {
  List<HealthQuestion> _apiQuestions = [];
  List<bool?> _answers = [];
  List<TextEditingController> _controllers = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserSetupCubit>().fetchHealthQuestions();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onNextPressed() {
    if (_answers.contains(null) || _answers.length < _apiQuestions.length) {
      showAppSnackBar(context, text: 'auth_health_validation_err'.tr(), isError: true);
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final answersList = <HealthAnswerItem>[];
      for (int i = 0; i < _apiQuestions.length; i++) {
        answersList.add(
          HealthAnswerItem(
            questionId: _apiQuestions[i].id,
            answer: _answers[i] ?? false,
            details: _answers[i] == true ? _controllers[i].text.trim() : null,
          ),
        );
      }
      context.read<UserSetupCubit>().submitHealthAnswers(answersList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserSetupCubit, UserSetupState>(
      listener: (context, state) {
        if (state is HealthQuestionsLoadSuccess) {
          setState(() {
            _apiQuestions = state.questions;
            _answers = List.filled(_apiQuestions.length, null);
            _controllers = List.generate(
              _apiQuestions.length,
              (_) => TextEditingController(),
            );
          });
        } else if (state is SubmitHealthAnswersSuccess) {
          showAppSnackBar(context, text: state.message, isSuccess: true);
          context.push(UserAppRoutes.bmiReport);
        } else if (state is UserSetupFailure) {
          showAppSnackBar(context, text: state.message, isError: true);
        }
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
                child: TopCenteredConstrainedBox(
                  horizontalPadding: 0,
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
                            if (_apiQuestions.isEmpty && !isLoading)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.h),
                                child: Text(
                                  'لا توجد أسئلة صحية متاحة حالياً.',
                                  style: TextStyleManager.style14Medium,
                                ),
                              ),
                            ...List.generate(_apiQuestions.length, (index) {
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
            ),
          ),
        );
      },
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
                  _apiQuestions[index].text,
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
