import 'dart:ui' as ui;
import 'package:fitness_day/core/widgets/upcoming_visit_show_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/utils/date_time_utils.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/message_icon_button.dart';
import 'package:fitness_day/core/utils/decimal_input_formatter.dart';
import 'package:fitness_day/core/utils/measurement.dart';
import 'package:fitness_day/core/utils/validators.dart';
import 'package:fitness_day/features/shared/conversations/presentation/utils/open_client_chat.dart';
import 'package:fitness_day/core/widgets/add_goal_dialog.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/plan_item_card.dart';
import 'package:fitness_day/core/widgets/vertical_day_tab_bar.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/specialist/visits/presentation/widgets/report_text_field.dart';
import 'add_activity_page.dart';
import 'add_exercise_page.dart';
import 'add_meal_page.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import '../manager/visit_details_cubit.dart';
import '../manager/visit_details_state.dart';
import '../../data/models/specialist_assessment_visit_data_model.dart';
import '../../data/models/assessment_current_state.dart';
import '../../data/models/specialist_assessment_health_report_model.dart';
import '../../data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';

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
  final TextEditingController _musclePercentageController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();

  /// Report fields in the order they appear on screen, paired with the
  /// controller they read and the rule they must satisfy. Used both to
  /// validate the form in one pass and to pick which field to scroll to.
  late final List<
      ({String key, TextEditingController controller, String? Function(String) rule})>
      _reportFields = [
    (key: 'WEIGHT', controller: _weightController, rule: AppValidators.weight),
    (key: 'HEIGHT', controller: _heightController, rule: AppValidators.height),
    (
      key: 'FAT_PERCENTAGE',
      controller: _fatPercentageController,
      rule: _percentage
    ),
    (key: 'FAT_WEIGHT', controller: _fatWeightController, rule: _positiveNumber),
    (
      key: 'MUSCLE_WEIGHT',
      controller: _muscleWeightController,
      rule: _positiveNumber
    ),
    (key: 'BMR', controller: _bmrController, rule: _positiveNumber),
    (
      key: 'MUSCLE_PERCENTAGE',
      controller: _musclePercentageController,
      rule: _percentage
    ),
    (key: 'PROTEIN', controller: _proteinController, rule: _positiveNumber),
  ];

  @override
  void initState() {
    super.initState();
    // Editing a field drops the message pinned under it, so a corrected value
    // doesn't keep showing the reason it was rejected.
    for (final field in _reportFields) {
      field.controller.addListener(() {
        if (_reportErrors.remove(field.key) != null && mounted) setState(() {});
      });
    }
  }

  /// Required, numeric, greater than zero.
  String? _positiveNumber(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return 'visit_details.field_required'.tr();
    final value = double.tryParse(text);
    if (value == null) return 'visit_details.field_invalid_number'.tr();
    if (value <= 0) return 'visit_details.field_must_be_positive'.tr();
    return null;
  }

  /// Required, numeric, within 0–100.
  String? _percentage(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return 'visit_details.field_required'.tr();
    final value = double.tryParse(text);
    if (value == null) return 'visit_details.field_invalid_number'.tr();
    if (value <= 0 || value > 100) {
      return 'visit_details.field_percentage_range'.tr();
    }
    return null;
  }

  /// Checks the whole report in one pass.
  ///
  /// The API reports a single rejected field per response, so saving a form
  /// with several blanks meant fixing one, saving, being told about the next,
  /// and round-tripping through the server for each one. Every offending field
  /// is flagged here at once, before anything is sent.
  ///
  /// BMI is left out on purpose — it is derived from weight and height below
  /// rather than typed, so requiring it would be asking for a value the screen
  /// already knows.
  Map<String, String> _validateReport() {
    final errors = <String, String>{};
    for (final field in _reportFields) {
      final error = field.rule(field.controller.text);
      if (error != null) errors[field.key] = error;
    }
    return errors;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _bmiController.dispose();
    _fatPercentageController.dispose();
    _fatWeightController.dispose();
    _muscleWeightController.dispose();
    _bmrController.dispose();
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

  String _formatUpcomingVisitTime(SpecialistAssessmentVisitDataModel visitData) {
    return formatVisitDate(visitData.weekStart, context);
  }

  void _onDayChanged(int dayIndex) {
    setState(() {
      _selectedDayIndex = dayIndex;
    });
    context.read<VisitDetailsCubit>().loadCustomPlan(widget.assessmentId, dayIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisitDetailsCubit, VisitDetailsState>(
      builder: (context, topState) {
        // The caller only knows the visit's status at navigation time (e.g. Home's
        // upcoming list doesn't carry isStarted), so its isUpcoming hint can be wrong.
        // Wait for real visit data before choosing a screen — guessing from the hint
        // would flash the wrong screen (or wrong button) for a frame, then snap to the
        // correct one once data loads.
        final loadedVisitData = topState is VisitDetailsSuccess ? topState.visitData : null;

        if (loadedVisitData == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // currentState is the authoritative signal, but it's null if the backend
        // hasn't sent it for this response — fall back to isStarted rather than
        // silently assuming NOT_STARTED, which would hide the whole real screen
        // (tabs, goal card, everything) for a visit that's actually in progress.
        final assessmentState = loadedVisitData.currentState;
        final effectiveIsUpcoming = assessmentState != null
            ? assessmentState == AssessmentCurrentState.notStarted
            : !loadedVisitData.isStarted;

        if (effectiveIsUpcoming) {
      return UpcomingVisitShowScreen(
        title: 'visit_details.title'.tr(),
        trailingWidget: MessageIconButton(
          onTap: () => openClientChat(
            context,
            clientId: loadedVisitData.user?.id,
            conversationId: loadedVisitData.conversationId,
            clientName: loadedVisitData.user?.name,
          ),
        ),
        visitTimeRemaining: formatVisitTimeRemaining(loadedVisitData.weekStart, context),
        // Straight from GET /specialist/assessment-history/details/:id — the
        // response carries name, description and user.name, but the screen was
        // still rendering the placeholder strings the layout was built with.
        visitTitle: loadedVisitData.name,
        visitSubtitle: loadedVisitData.description,
        personName: loadedVisitData.user?.name ?? '',
        personNameLabel: 'visits.client_name_label'.tr(),
        visitTime: _formatUpcomingVisitTime(loadedVisitData),
        visitLocation: loadedVisitData.placement,
        visitGoalTitle: 'visit_details.visit_goal_title'.tr(),
        // The four goal_N strings were placeholders too. The response has one
        // `goal` field; the section stays hidden as before, so flipping
        // showGoal on now surfaces the real goal rather than the sample text.
        visitGoals: [
          if ((loadedVisitData.goal ?? '').isNotEmpty) loadedVisitData.goal!,
        ],
        showGoal: false,
        bottomAction: BlocBuilder<VisitDetailsCubit, VisitDetailsState>(
          builder: (context, state) {
            final isStarting = state is VisitDetailsSuccess && state.isStarting;
            return SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'visit_details.start_visit'.tr(),
                isLoading: isStarting,
                onPressed: isStarting
                    ? null
                    : () async {
                          final cubit = context.read<VisitDetailsCubit>();
                          final result = await cubit.startVisit(widget.assessmentId);
                          final success = result.$1;
                          final message = result.$2;
                          if (success && context.mounted) {
                            showAppSnackBar(context, text: 'visit_details.start_success'.tr(), isSuccess: true);
                            await cubit.loadVisitData(widget.assessmentId, forceRefresh: true);
                          } else if (context.mounted) {
                            showAppSnackBar(context, text: message, isError: true);
                          }
                        }

                      
              ),
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
                            onTap: () => openClientChat(
                              context,
                              clientId: loadedVisitData.user?.id,
                              conversationId: loadedVisitData.conversationId,
                              clientName: loadedVisitData.user?.name,
                            ),
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
                              return AppErrorView(
                                error: state.error,
                                message: state.message,
                                onRetry: () => context
                                    .read<VisitDetailsCubit>()
                                    .loadVisitData(widget.assessmentId,
                                        forceRefresh: true),
                              );
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
              // button state is driven by the assessment's currentState:
              // IN_PROGRESS -> disabled "finish", READY_TO_FINISH -> active "finish",
              // COMPLETED / NOT_STARTED -> hidden (NOT_STARTED is handled by the Upcoming screen instead)
              if (!effectiveIsUpcoming && _selectedTabIndex == 2)
                BlocBuilder<VisitDetailsCubit, VisitDetailsState>(
                  builder: (context, state) {
                    final visitData = state is VisitDetailsSuccess ? state.visitData : null;
                    final currentState = visitData?.currentState;
                    final isFinishing = state is VisitDetailsSuccess && state.isStarting;

                    if (currentState == AssessmentCurrentState.completed ||
                        currentState == AssessmentCurrentState.notStarted) {
                      return const SizedBox.shrink();
                    }

                    // currentState missing (backend hasn't sent it) — fall back to
                    // canFinishAssessment rather than hiding the button outright.
                    final canFinish = currentState != null
                        ? currentState == AssessmentCurrentState.readyToFinish
                        : (state is VisitDetailsSuccess && state.canFinishAssessment);

                    return Container(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                      child: canFinish
                          ? CustomButton(
                              text: 'visit_details.end_visit'.tr(),
                              color: AppColors.primary,
                              isLoading: isFinishing,
                              onPressed: isFinishing
                                  ? null
                                  : () async {
                                      final cubit = context.read<VisitDetailsCubit>();
                                      final (success, message) = await cubit.finishVisit(widget.assessmentId);
                                      if (mounted) {
                                        showAppSnackBar(context, text: message, isSuccess: success, isError: !success);
                                      }
                                      if (success && mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
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
      },
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
          // Prefer currentState (authoritative) over isStarted, which some responses
          // (e.g. COMPLETED assessments) don't send at all — that would otherwise
          // default to false and hide the goal card for a visit that's clearly done.
          if (visitData.currentState != null
              ? visitData.currentState != AssessmentCurrentState.notStarted
              : visitData.isStarted)
            VisitGoalCard(
              title: 'visit_details.visit_goal_title'.tr(),
              goals: goalsList,
              onAddPressed: () {
                showAddGoalDialog(
                  context: context,
                  initialGoal: visitData.goal ?? '',
                  onSave: (goal) async {
                    final cubit = context.read<VisitDetailsCubit>();
                    final (success, message) = await cubit.updateGoal(widget.assessmentId, goal);
                    if (mounted) {
                      showAppSnackBar(context, text: message, isSuccess: success, isError: !success);
                    }
                    if (success && mounted) {
                      _onTabChanged(1);
                    }
                  },
                );
              },
              onEditPressed: () {
                showAddGoalDialog(
                  context: context,
                  initialGoal: visitData.goal ?? '',
                  onSave: (goal) async {
                    final cubit = context.read<VisitDetailsCubit>();
                    final (success, message) = await cubit.updateGoal(widget.assessmentId, goal);
                    if (mounted) {
                      showAppSnackBar(context, text: message, isSuccess: success, isError: !success);
                    }
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

    // Weight and height keep their decimals — `toStringAsFixed(0)` loaded a
    // 70.5 kg client as "70", and saving without touching the field silently
    // wrote that rounded-down value back to the server.
    if (healthReport.weight?.value != null && healthReport.weight!.value > 0) {
      _weightController.text = Measurement.format(healthReport.weight!.value);
    }
    if (healthReport.height?.value != null && healthReport.height!.value > 0) {
      _heightController.text = Measurement.format(healthReport.height!.value);
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

  final Map<String, String> _reportErrors = {};

  /// Brings the field carrying [errorKey] into view so the error under it is
  /// actually read rather than sitting off-screen.
  void _scrollToField(String errorKey) {
    final targetKey = _fieldKeys[errorKey];
    if (targetKey?.currentContext == null) return;
    Scrollable.ensureVisible(
      targetKey!.currentContext!,
      duration: const Duration(milliseconds: 300),
      alignment: 0.3,
    );
  }

  final Map<String, GlobalKey> _fieldKeys = {
    'WEIGHT': GlobalKey(),
    'HEIGHT': GlobalKey(),
    'BMI': GlobalKey(),
    'FAT_PERCENTAGE': GlobalKey(),
    'FAT_WEIGHT': GlobalKey(),
    'MUSCLE_WEIGHT': GlobalKey(),
    'BMR': GlobalKey(),
    'MUSCLE_PERCENTAGE': GlobalKey(),
    'PROTEIN': GlobalKey(),
  };

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
            fieldKey: _fieldKeys['WEIGHT'],
            label: '${'visit_details.weight'.tr()} :',
            hintText: 'visit_details.write_weight'.tr(),
            suffixText: healthReport.weight?.unit ?? 'visit_details.kg'.tr(),
            controller: _weightController,
            errorText: _reportErrors['WEIGHT'],
            inputFormatters: [DecimalInputFormatter()],
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            fieldKey: _fieldKeys['HEIGHT'],
            label: '${'visit_details.height'.tr()} :',
            hintText: 'visit_details.write_height'.tr(),
            suffixText: healthReport.height?.unit ?? 'visit_details.cm'.tr(),
            controller: _heightController,
            errorText: _reportErrors['HEIGHT'],
            inputFormatters: [DecimalInputFormatter()],
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            fieldKey: _fieldKeys['BMI'],
            label: 'visit_details.bmi'.tr(),
            hintText: 'visit_details.bmi'.tr(),
            controller: _bmiController,
            errorText: _reportErrors['BMI'],
            inputFormatters: [DecimalInputFormatter()],
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            fieldKey: _fieldKeys['FAT_PERCENTAGE'],
            label: 'visit_details.body_fat_percentage'.tr(),
            hintText: 'visit_details.write_body_fat_percentage'.tr(),
            suffixText: healthReport.fatPercentage?.unit ?? '%',
            controller: _fatPercentageController,
            errorText: _reportErrors['FAT_PERCENTAGE'],
            inputFormatters: [DecimalInputFormatter()],
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            fieldKey: _fieldKeys['FAT_WEIGHT'],
            label: 'visit_details.fat_mass'.tr(),
            hintText: 'visit_details.fat_mass'.tr(),
            suffixText: healthReport.fatWeight?.unit ?? 'visit_details.kg'.tr(),
            controller: _fatWeightController,
            errorText: _reportErrors['FAT_WEIGHT'],
            inputFormatters: [DecimalInputFormatter()],
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            fieldKey: _fieldKeys['MUSCLE_WEIGHT'],
            label: 'visit_details.muscle_weight'.tr(),
            hintText: 'visit_details.muscle_weight'.tr(),
            suffixText: healthReport.muscleWeight?.unit ?? 'visit_details.kg'.tr(),
            controller: _muscleWeightController,
            errorText: _reportErrors['MUSCLE_WEIGHT'],
            inputFormatters: [DecimalInputFormatter()],
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            fieldKey: _fieldKeys['BMR'],
            label: '${'visit_details.metabolic_rate'.tr()} :',
            hintText: 'visit_details.write_total_metabolic_rate'.tr(),
            suffixText: healthReport.bmr?.unit ?? '',
            controller: _bmrController,
            errorText: _reportErrors['BMR'],
            inputFormatters: [DecimalInputFormatter(maxIntegerDigits: 5)],
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            fieldKey: _fieldKeys['MUSCLE_PERCENTAGE'],
            label: '${'visit_details.muscle_percentage'.tr()} :',
            hintText: 'visit_details.write_muscle_percentage'.tr(),
            suffixText: healthReport.musclePercentage?.unit ?? '%',
            controller: _musclePercentageController,
            errorText: _reportErrors['MUSCLE_PERCENTAGE'],
            inputFormatters: [DecimalInputFormatter()],
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            fieldKey: _fieldKeys['PROTEIN'],
            label: 'visit_details.protein'.tr(),
            hintText: 'visit_details.write_protein'.tr(),
            suffixText: healthReport.protein?.unit ?? '',
            controller: _proteinController,
            errorText: _reportErrors['PROTEIN'],
            inputFormatters: [DecimalInputFormatter()],
          ),
          SizedBox(height: 24.h),
          CustomButton(
            text: 'visit_details.save'.tr(),
            onPressed: () async {
              FocusScope.of(context).unfocus();

              setState(() {
                _reportErrors.clear();
              });

              // Check every field locally first. `?? 0.0` used to turn an
              // empty or malformed field into a real 0 and post it, and the
              // specialist only learned about it from the server's reply —
              // one field at a time.
              final errors = _validateReport();
              if (errors.isNotEmpty) {
                setState(() => _reportErrors.addAll(errors));
                _scrollToField(
                  _reportFields.firstWhere((f) => errors.containsKey(f.key)).key,
                );
                return;
              }

              final weight = Measurement.round(
                Measurement.parse(_weightController.text)!,
              );
              final height = Measurement.round(
                Measurement.parse(_heightController.text)!,
              );

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

              final (success, message, errorKey) = await cubit.updateHealthReport(
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

              if (!success && errorKey != null && mounted) {
                setState(() {
                  _reportErrors[errorKey] = message;
                });
                _scrollToField(errorKey);
              } else if (!success && mounted) {
                showAppSnackBar(context, text: message, isError: true);
              }

              if (success && mounted) {
                showAppSnackBar(context, text: message, isSuccess: true);
                _onTabChanged(2);
              }
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
        VerticalDayTabBar(
          days: [
            'visit_details.day_1'.tr(),
            'visit_details.day_2'.tr(),
            'visit_details.day_3'.tr(),
            'visit_details.day_4'.tr(),
            'visit_details.day_5'.tr(),
            'visit_details.day_6'.tr(),
            'visit_details.day_7'.tr(),
          ],
          selectedIndex: _selectedDayIndex,
          onDaySelected: _onDayChanged,
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
        final localDate = parsed.isUtc ? parsed.toLocal() : parsed;
        formattedTime = DateFormat('hh:mm a', context.locale.languageCode).format(localDate);
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
        final localDate = parsed.isUtc ? parsed.toLocal() : parsed;
        formattedTime = DateFormat('hh:mm a', context.locale.languageCode).format(localDate);
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
