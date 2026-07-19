import 'dart:ui' as ui;
import 'package:fitness_day/core/widgets/upcoming_visit_show_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/message_icon_button.dart';
import 'package:fitness_day/core/widgets/reschedule_visit_dialog.dart';
import 'package:fitness_day/core/widgets/add_goal_dialog.dart';
import 'package:fitness_day/core/widgets/plan_item_card.dart';
import 'package:fitness_day/core/widgets/vertical_tab_bar.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/specialist/visits/presentation/widgets/report_text_field.dart';
import '../../../../shared/conversations/presentation/pages/chat_details_page.dart';
import 'add_activity_page.dart';
import 'add_exercise_page.dart';
import 'add_meal_page.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import '../manager/visit_details_cubit.dart';
import '../manager/visit_details_state.dart';
import '../../data/models/specialist_assessment_visit_data_model.dart';
import '../../data/models/specialist_assessment_health_report_model.dart';
import '../../data/models/specialist_assessment_custom_plan_model.dart';

class VisitDetailsPage extends StatelessWidget {
  final bool isUpcoming;
  final String assessmentId;

  const VisitDetailsPage({
    super.key,
    required this.assessmentId,
    this.isUpcoming = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<VisitDetailsCubit>()
        ..loadVisitData(assessmentId),
      child: _VisitDetailsPageContent(
        assessmentId: assessmentId,
        isUpcoming: isUpcoming,
      ),
    );
  }
}

class _VisitDetailsPageContent extends StatefulWidget {
  final String assessmentId;
  final bool isUpcoming;

  const _VisitDetailsPageContent({
    super.key,
    required this.assessmentId,
    this.isUpcoming = false,
  });

  @override
  State<_VisitDetailsPageContent> createState() => _VisitDetailsPageContentState();
}

class _VisitDetailsPageContentState extends State<_VisitDetailsPageContent> {
  int _selectedTabIndex = 0;
  int _selectedDayIndex = 0;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _fatPercentageController = TextEditingController();
  final TextEditingController _fatWeightController = TextEditingController();
  final TextEditingController _muscleWeightController = TextEditingController();
  final TextEditingController _bmrController = TextEditingController();
  final TextEditingController _leanMassController = TextEditingController();
  final TextEditingController _musclePercentageController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _bmiController.dispose();
    _fatPercentageController.dispose();
    _fatWeightController.dispose();
    _muscleWeightController.dispose();
    _bmrController.dispose();
    _leanMassController.dispose();
    _musclePercentageController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
      if (index == 1) {
        // Reset flag so fields get re-populated when switching back to report tab
        _reportFieldsPopulated = false;
      }
    });

    final cubit = context.read<VisitDetailsCubit>();
    if (index == 0) {
      cubit.loadVisitData(widget.assessmentId);
    } else if (index == 1) {
      cubit.loadHealthReport(widget.assessmentId);
    } else if (index == 2) {
      cubit.loadCustomPlan(widget.assessmentId, _selectedDayIndex + 1);
    }
  }

  void _onDayChanged(int dayIndex) {
    setState(() {
      _selectedDayIndex = dayIndex;
    });
    context.read<VisitDetailsCubit>().loadCustomPlan(widget.assessmentId, dayIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isUpcoming) {
      return UpcomingVisitShowScreen(
        title: 'visit_details.title'.tr(),
        trailingWidget: MessageIconButton(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatDetailsPage()),
            );
          },
        ),
        visitTimeRemaining: 'visits.in_minutes'.tr(args: ['25']),
        visitTitle: 'visits.dummy_title'.tr(),
        visitSubtitle: 'visits.dummy_subtitle'.tr(),
        personName: 'visits.dummy_client'.tr(),
        personNameLabel: 'visits.client_name_label'.tr(),
        visitTime: '${'visits.today'.tr()} 4:30 ${'visits.pm'.tr()}',
        visitLocation: 'visits.hq_location'.tr(),
        visitGoalTitle: 'visit_details.visit_goal_title'.tr(),
        visitGoals: [
          'visit_details.goal_1'.tr(),
          'visit_details.goal_2'.tr(),
          'visit_details.goal_3'.tr(),
          'visit_details.goal_4'.tr(),
        ],
        showGoal: false,
        bottomAction: BlocBuilder<VisitDetailsCubit, VisitDetailsState>(
          builder: (context, state) {
            final isStarting = state is VisitDetailsSuccess && state.isStarting;
            return Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'visit_details.start_visit'.tr(),
                    isLoading: isStarting,
                    onPressed: isStarting
                        ? null
                        : () async {
                            final cubit = context.read<VisitDetailsCubit>();
                            final messenger = ScaffoldMessenger.of(context);
                            final success = await cubit.startVisit(widget.assessmentId);
                            if (success && context.mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('visit_details.start_success'.tr()),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                              cubit.loadVisitData(widget.assessmentId);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: cubit,
                                    child: _VisitDetailsPageContent(
                                      assessmentId: widget.assessmentId,
                                      isUpcoming: false,
                                    ),
                                  ),
                                ),
                              );
                            } else if (!success && context.mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('shared_val_err_required'.tr()),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomOutlinedButton(
                    text: 'visit_details.reschedule'.tr(),
                    onPressed: () {
                      showRescheduleDialog(context, widget.assessmentId);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
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

                      // 1. Back Header
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: AppBackHeader(
                          title: 'visit_details.title'.tr(),
                          trailingWidget: MessageIconButton(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ChatDetailsPage()),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // 2. Segmented Control (3 tabs)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: AppSegmentedControl(
                          type: AppSegmentedControlType.unified,
                          items: [
                            'visit_details.tab_visit_data'.tr(),
                            'visit_details.tab_report'.tr(),
                            'visit_details.tab_custom_plan'.tr(),
                          ],
                          selectedIndex: _selectedTabIndex,
                          onItemSelected: _onTabChanged,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // 3. Content Area
                      Expanded(
                        child: BlocBuilder<VisitDetailsCubit, VisitDetailsState>(
                          builder: (context, state) {
                            if (state is VisitDetailsLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (state is VisitDetailsFailure) {
                              return Center(child: Text(state.message));
                            }
                            if (state is VisitDetailsSuccess) {
                              return SingleChildScrollView(
                                padding: EdgeInsets.only(bottom: 24.h),
                                child: _buildTabContent(state),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),

              // 4. Bottom Buttons — always visible in Custom Plan tab
              // disabled (outlined) when canFinishAssessment == false, active (greenMint) when true
              if (!widget.isUpcoming && _selectedTabIndex == 2)
                BlocBuilder<VisitDetailsCubit, VisitDetailsState>(
                  builder: (context, state) {
                    final canFinish = state is VisitDetailsSuccess && state.canFinishAssessment;
                    return Container(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                      child: canFinish
                          ? CustomButton(
                              text: 'visit_details.end_visit'.tr(),
                              color: AppColors.greenMint,
                              onPressed: () {},
                            )
                          : _buildDisabledEndVisitButton(),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(VisitDetailsSuccess state) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildVisitDataTab(state.visitData);
      case 1:
        return _buildReportTab(state.healthReport);
      case 2:
        if (state.visitData == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildCustomPlanTab(
          state.customPlan,
          _selectedDayIndex + 1,
          state.visitData!.weekStart,
        );
      default:
        return _buildVisitDataTab(state.visitData);
    }
  }

  Widget _buildVisitDataTab(SpecialistAssessmentVisitDataModel? visitData) {
    if (visitData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    String formattedTime = '';
    if (visitData.weekStart.isNotEmpty) {
      final parsed = DateTime.tryParse(visitData.weekStart);
      if (parsed != null) {
        formattedTime = DateFormat('yyyy-MM-dd hh:mm a', context.locale.languageCode)
            .format(parsed.toLocal());
      }
    }
    if (formattedTime.isEmpty) {
      formattedTime = visitData.weekStart;
    }

    final goalsList = (visitData.goal ?? '')
        .split('\n')
        .map((e) => e.replaceAll('•', '').trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          VisitCard(
            timeRemaining: widget.isUpcoming
                ? "home.commitment_rate".tr(args: [visitData.adherenceRate.toInt().toString()])
                : '',
            title: visitData.name,
            subtitle: visitData.description,
            personName: visitData.user?.name ?? '',
            visitTime: formattedTime,
            location: visitData.placement,
            buttonText: 'visits.view_visit'.tr(),
            onViewPressed: () {},
            isUpcoming: widget.isUpcoming,
            showButton: false,
          ),
          SizedBox(height: 16.h),
          if (visitData.isStarted)
            VisitGoalCard(
              title: 'visit_details.visit_goal_title'.tr(),
              goals: goalsList,
              onAddPressed: () {
                showAddGoalDialog(
                  context: context,
                  initialGoal: visitData.goal ?? '',
                  onSave: (goal) async {
                    final cubit = context.read<VisitDetailsCubit>();
                    final messenger = ScaffoldMessenger.of(context);
                    final (success, message) = await cubit.updateGoal(widget.assessmentId, goal);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: success ? AppColors.primary : AppColors.error,
                      ),
                    );
                  },
                );
              },
              onEditPressed: () {
                showAddGoalDialog(
                  context: context,
                  initialGoal: visitData.goal ?? '',
                  onSave: (goal) async {
                    final cubit = context.read<VisitDetailsCubit>();
                    final messenger = ScaffoldMessenger.of(context);
                    final (success, message) = await cubit.updateGoal(widget.assessmentId, goal);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: success ? AppColors.primary : AppColors.error,
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  bool _reportFieldsPopulated = false;

  void _populateReportFields(SpecialistAssessmentHealthReportModel healthReport) {
    if (_reportFieldsPopulated) return;
    _reportFieldsPopulated = true;

    if (healthReport.weight?.value != null && healthReport.weight!.value > 0) {
      _weightController.text = healthReport.weight!.value.toStringAsFixed(0);
    }
    if (healthReport.height?.value != null && healthReport.height!.value > 0) {
      _heightController.text = healthReport.height!.value.toStringAsFixed(0);
    }
    if (healthReport.bmi?.value != null && healthReport.bmi!.value > 0) {
      _bmiController.text = healthReport.bmi!.value.toStringAsFixed(2);
    }
    if (healthReport.fatPercentage?.value != null && healthReport.fatPercentage!.value > 0) {
      _fatPercentageController.text = healthReport.fatPercentage!.value.toStringAsFixed(0);
    }
    if (healthReport.fatWeight?.value != null && healthReport.fatWeight!.value > 0) {
      _fatWeightController.text = healthReport.fatWeight!.value.toStringAsFixed(0);
    }
    if (healthReport.muscleWeight?.value != null && healthReport.muscleWeight!.value > 0) {
      _muscleWeightController.text = healthReport.muscleWeight!.value.toStringAsFixed(0);
    }
    if (healthReport.bmr?.value != null && healthReport.bmr!.value > 0) {
      _bmrController.text = healthReport.bmr!.value.toStringAsFixed(0);
    }
    if (healthReport.musclePercentage?.value != null && healthReport.musclePercentage!.value > 0) {
      _musclePercentageController.text = healthReport.musclePercentage!.value.toStringAsFixed(0);
    }
    if (healthReport.protein?.value != null && healthReport.protein!.value > 0) {
      _proteinController.text = healthReport.protein!.value.toStringAsFixed(0);
    }
  }

  Widget _buildReportTab(SpecialistAssessmentHealthReportModel? healthReport) {
    if (healthReport == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Pre-populate fields with existing data on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _populateReportFields(healthReport);
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          ReportTextField(
            label: '${'visit_details.weight'.tr()} :',
            hintText: 'visit_details.write_weight'.tr(),
            suffixText: healthReport.weight?.unit ?? 'visit_details.kg'.tr(),
            controller: _weightController,
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: '${'visit_details.height'.tr()} :',
            hintText: 'visit_details.write_height'.tr(),
            suffixText: healthReport.height?.unit ?? 'visit_details.cm'.tr(),
            controller: _heightController,
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.bmi'.tr(),
            hintText: 'visit_details.bmi'.tr(),
            controller: _bmiController,
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.body_fat_percentage'.tr(),
            hintText: 'visit_details.write_body_fat_percentage'.tr(),
            suffixText: healthReport.fatPercentage?.unit ?? '%',
            controller: _fatPercentageController,
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.fat_mass'.tr(),
            hintText: 'visit_details.fat_mass'.tr(),
            suffixText: healthReport.fatWeight?.unit ?? 'visit_details.kg'.tr(),
            controller: _fatWeightController,
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.muscle_weight'.tr(),
            hintText: 'visit_details.muscle_weight'.tr(),
            suffixText: healthReport.muscleWeight?.unit ?? 'visit_details.kg'.tr(),
            controller: _muscleWeightController,
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: '${'visit_details.metabolic_rate'.tr()} :',
            hintText: 'visit_details.write_total_metabolic_rate'.tr(),
            suffixText: healthReport.bmr?.unit ?? '',
            controller: _bmrController,
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.lean_mass'.tr(),
            hintText: 'visit_details.write_lean_mass'.tr(),
            controller: _leanMassController,
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: '${'visit_details.muscle_percentage'.tr()} :',
            hintText: 'visit_details.write_muscle_percentage'.tr(),
            suffixText: healthReport.musclePercentage?.unit ?? '%',
            controller: _musclePercentageController,
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.protein_percentage'.tr(),
            hintText: 'visit_details.write_protein_percentage'.tr(),
            suffixText: healthReport.protein?.unit ?? '',
            controller: _proteinController,
          ),
          SizedBox(height: 24.h),
          CustomButton(
            text: 'visit_details.save'.tr(),
            onPressed: () async {
              final weight = double.tryParse(_weightController.text) ?? 0.0;
              final height = double.tryParse(_heightController.text) ?? 0.0;

              double parsedBmi = 0.0;
              if (weight > 0 && height > 0) {
                parsedBmi = double.parse((weight / ((height / 100) * (height / 100))).toStringAsFixed(2));
              } else {
                final bmiText = _bmiController.text.trim();
                if (bmiText.isNotEmpty) {
                  final firstWord = bmiText.split(RegExp(r'\s+')).first;
                  parsedBmi = double.tryParse(firstWord) ?? 0.0;
                }
              }

              final fatPercentage = double.tryParse(_fatPercentageController.text) ?? 0.0;
              final fatWeight = double.tryParse(_fatWeightController.text) ?? 0.0;
              final muscleWeight = double.tryParse(_muscleWeightController.text) ?? 0.0;
              final bmr = double.tryParse(_bmrController.text) ?? 0.0;
              final musclePercentage = double.tryParse(_musclePercentageController.text) ?? 0.0;
              final protein = double.tryParse(_proteinController.text) ?? 0.0;

              final cubit = context.read<VisitDetailsCubit>();
              final messenger = ScaffoldMessenger.of(context);

              final (success, message) = await cubit.updateHealthReport(
                assessmentId: widget.assessmentId,
                weight: weight,
                height: height,
                bmi: parsedBmi,
                bmr: bmr,
                fatWeight: fatWeight,
                fatPercentage: fatPercentage,
                muscleWeight: muscleWeight,
                musclePercentage: musclePercentage,
                protein: protein,
              );

              messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: success ? AppColors.primary : AppColors.error,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPlanTab(
    SpecialistAssessmentCustomPlanModel? plan,
    int dayNumber,
    String weekStart,
  ) {
    if (plan == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content Area (Right side in RTL)
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActionCard(
                  title: 'visit_details.add_meal'.tr(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => BlocProvider.value(
                          value: context.read<VisitDetailsCubit>(),
                          child: AddMealPage(
                            assessmentId: widget.assessmentId,
                            dayNumber: dayNumber,
                            weekStart: weekStart,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                _buildActionCard(
                  title: 'visit_details.add_exercise'.tr(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => BlocProvider.value(
                          value: context.read<VisitDetailsCubit>(),
                          child: AddExercisePage(
                            assessmentId: widget.assessmentId,
                            dayNumber: dayNumber,
                            weekStart: weekStart,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                _buildActionCard(
                  title: 'visit_details.add_activity'.tr(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => BlocProvider.value(
                          value: context.read<VisitDetailsCubit>(),
                          child: AddActivityPage(
                            assessmentId: widget.assessmentId,
                            dayNumber: dayNumber,
                            weekStart: weekStart,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 32.h),

                // Added Items Lists
                _buildSectionTitle('visit_details.nutrition'.tr(), plan.meals.length),
                SizedBox(height: 12.h),
                if (plan.meals.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      'visit_details.no_meals'.tr(),
                      style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...plan.meals.map((meal) => _buildMealCard(meal, dayNumber, weekStart)),

                SizedBox(height: 24.h),
                _buildSectionTitle('visit_details.exercises'.tr(), plan.workoutPlan.length),
                SizedBox(height: 12.h),
                if (plan.workoutPlan.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      'visit_details.no_exercises'.tr(),
                      style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...plan.workoutPlan.map((workout) => _buildExerciseCard(workout, dayNumber, weekStart)),

                SizedBox(height: 24.h),
                _buildSectionTitle('visit_details.activity'.tr(), plan.activities.length),
                SizedBox(height: 12.h),
                if (plan.activities.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      'visit_details.no_activities'.tr(),
                      style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...plan.activities.map((activity) => _buildActivityCard(activity, dayNumber, weekStart)),
              ],
            ),
          ),
        ),
        // Vertical Tab Bar (Left side in RTL)
        VerticalTabBar(
          items: [
            'visit_details.day_1'.tr(),
            'visit_details.day_2'.tr(),
            'visit_details.day_3'.tr(),
            'visit_details.day_4'.tr(),
            'visit_details.day_5'.tr(),
            'visit_details.day_6'.tr(),
            'visit_details.day_7'.tr(),
          ],
          selectedIndex: _selectedDayIndex,
          onItemSelected: _onDayChanged,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyleManager.style11Medium),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
              minimumSize: const Size(0, 0),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'visit_details.add'
                      .tr()
                      .replaceAll('»', '')
                      .replaceAll('«', '')
                      .trim(),
                  style: TextStyleManager.smallButtons.copyWith(
                    color: AppColors.white,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Directionality.of(context) == ui.TextDirection.rtl
                      ? Icons.keyboard_double_arrow_left
                      : Icons.keyboard_double_arrow_right,
                  size: 16.sp,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledEndVisitButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          disabledForegroundColor: AppColors.textSecondary.withValues(alpha: 0.5),
          side: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        child: Text(
          'visit_details.end_visit'.tr(),
          style: TextStyleManager.button.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyleManager.heading2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          count.toString(),
          style: TextStyleManager.heading3.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(SpecialistMealModel meal, int dayNumber, String weekStart) {
    String formattedTime = '';
    if (meal.time.isNotEmpty) {
      final parsed = DateTime.tryParse(meal.time);
      if (parsed != null) {
        formattedTime = DateFormat('hh:mm a', context.locale.languageCode).format(parsed.toLocal());
      }
    }
    if (formattedTime.isEmpty) {
      formattedTime = meal.time;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: PlanItemCard(
        title: meal.name,
        isCompleted: meal.isCompleted,
        time: formattedTime,
        subtitle: meal.categoryName,
        showActions: true,
        onEditPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => BlocProvider.value(
                value: context.read<VisitDetailsCubit>(),
                child: AddMealPage(
                  assessmentId: widget.assessmentId,
                  dayNumber: dayNumber,
                  weekStart: weekStart,
                  mealId: meal.mealId,
                  initialCategoryName: meal.categoryName,
                  initialMealName: meal.name,
                  initialTime: meal.time,
                ),
              ),
            ),
          );
        },
        details: Row(
          children: [
            if (meal.image.isNotEmpty) ...[
              AppImage(
                meal.image,
                height: 50.h,
                width: 50.w,
                radius: 8.r,
              ),
              SizedBox(width: 12.w),
            ],
            RichText(
              text: TextSpan(
                style: TextStyleManager.style9Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(text: 'visit_details.calories_label'.tr()),
                  TextSpan(
                    text: '${meal.calories.toInt()} ',
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: 'visit_details.kcal'.tr()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(SpecialistWorkoutModel workout, int dayNumber, String weekStart) {
    String formattedTime = '';
    if (workout.time.isNotEmpty) {
      final parsed = DateTime.tryParse(workout.time);
      if (parsed != null) {
        formattedTime = DateFormat('hh:mm a', context.locale.languageCode).format(parsed.toLocal());
      }
    }
    if (formattedTime.isEmpty) {
      formattedTime = workout.time;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: PlanItemCard(
        title: workout.name,
        isCompleted: workout.isCompleted,
        time: formattedTime,
        subtitle: workout.description,
        showActions: true,
        onEditPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => BlocProvider.value(
                value: context.read<VisitDetailsCubit>(),
                child: AddExercisePage(
                  assessmentId: widget.assessmentId,
                  dayNumber: dayNumber,
                  weekStart: weekStart,
                  workoutItemId: workout.workoutItemId,
                ),
              ),
            ),
          );
        },
        details: Row(
          children: [
            if (workout.photo.isNotEmpty) ...[
              AppImage(
                workout.photo,
                height: 50.h,
                width: 50.w,
                radius: 8.r,
              ),
              SizedBox(width: 12.w),
            ],
            RichText(
              text: TextSpan(
                style: TextStyleManager.style9Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(text: 'visit_details.sets_label'.tr()),
                  TextSpan(
                    text: '${workout.completedSets} / ${workout.totalSets}',
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(SpecialistActivityModel activity, int dayNumber, String weekStart) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: PlanItemCard(
        title: activity.name,
        isCompleted: activity.isCompleted,
        subtitle: activity.description,
        showActions: true,
        onEditPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => BlocProvider.value(
                value: context.read<VisitDetailsCubit>(),
                child: AddActivityPage(
                  assessmentId: widget.assessmentId,
                  dayNumber: dayNumber,
                  weekStart: weekStart,
                  activityItemId: activity.activityItemId,
                ),
              ),
            ),
          );
        },
        details: Row(
          children: [
            if (activity.image.isNotEmpty) ...[
              AppImage(
                activity.image,
                height: 50.h,
                width: 50.w,
                radius: 8.r,
              ),
              SizedBox(width: 12.w),
            ],
            RichText(
              text: TextSpan(
                style: TextStyleManager.style9Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(text: 'visit_details.progress_label'.tr()),
                  TextSpan(
                    text: '${activity.currentProgress.toStringAsFixed(1)} / ${activity.goal.toInt()} ${activity.unit}',
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
