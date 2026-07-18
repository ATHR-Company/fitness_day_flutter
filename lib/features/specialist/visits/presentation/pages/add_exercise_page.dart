import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/selection_bottom_sheet.dart';
import 'package:fitness_day/core/widgets/app_text_field.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/specialist/visits/data/datasources/specialist_visits_remote_datasource.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_plan_lookups_model.dart';
import 'package:fitness_day/features/specialist/visits/presentation/manager/visit_details_cubit.dart';

import 'package:fitness_day/features/user/workout/data/models/workout_details_model.dart';

class AddExercisePage extends StatefulWidget {
  final String assessmentId;
  final int dayNumber;
  final String? workoutItemId; // If provided, it's Edit Mode

  const AddExercisePage({
    super.key,
    required this.assessmentId,
    required this.dayNumber,
    this.workoutItemId,
  });

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final _remoteDataSource = getIt<SpecialistVisitsRemoteDataSource>();

  List<SpecialistExerciseLookupModel> _exercises = [];
  SpecialistExerciseLookupModel? _selectedExercise;

  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _restController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _setsController.dispose();
    _restController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    try {
      final list = await _remoteDataSource.getExercises();
      _exercises = list;
    } catch (_) {}
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    await _loadExercises();

    if (widget.workoutItemId != null && _exercises.isNotEmpty) {
      try {
        final workoutDetailsResp = await _remoteDataSource.getWorkoutDetails(
          assessmentId: widget.assessmentId,
          dayNumber: widget.dayNumber,
          workoutItemId: widget.workoutItemId!,
        );
        final workoutDetails = workoutDetailsResp.data;

        if (workoutDetails != null) {
          // 1. Find and select exercise lookup by name
          final matchedExercise = _exercises.firstWhere(
            (e) => e.name.trim().toLowerCase() == workoutDetails.name.trim().toLowerCase(),
            orElse: () => _exercises.first,
          );
          _selectedExercise = matchedExercise;

          // 2. Set controllers
          _setsController.text = workoutDetails.sets.toString();
          _repsController.text = workoutDetails.reps.toString();
          _restController.text = workoutDetails.restDuration.toString();

          // 3. Parse time
          if (workoutDetails.time.isNotEmpty) {
            final parsed = DateTime.tryParse(workoutDetails.time);
            if (parsed != null) {
              _selectedTime = TimeOfDay.fromDateTime(parsed.toLocal());
            }
          }
        }
      } catch (_) {}
    }

    setState(() => _isLoading = false);
  }

  void _showExerciseNameSheet() {
    if (_exercises.isEmpty) return;
    final items = _exercises.map((e) => e.name).toList();
    showSelectionBottomSheet(
      context: context,
      title: 'add_exercise.exercise_type'.tr(),
      items: items,
      showSearch: true,
      initialSelectedIndex: _selectedExercise != null
          ? _exercises.indexOf(_selectedExercise!)
          : 0,
      onConfirm: (index) {
        setState(() {
          _selectedExercise = _exercises[index];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoaderHud(
      isCall: _isLoading,
      child: Scaffold(
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
                  child: AppBackHeader(
                    title: widget.workoutItemId != null ? 'تعديل التمرين' : 'add_exercise.title'.tr(),
                  ),
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
                              _selectedExercise?.name ??
                              'add_exercise.exercise_name_hint'.tr(),
                          suffixIcon: Icon(
                            Directionality.of(context) == ui.TextDirection.rtl
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                            size: 24.sp,
                          ),
                          onTap: _showExerciseNameSheet,
                          valueColor: _selectedExercise != null
                              ? AppColors.black
                              : AppColors.textSecondary.withValues(alpha: 0.5),
                          readOnly: true,
                        ),

                        SizedBox(height: 20.h),

                        // Exercise Time
                        AppFieldLabel(text: 'add_exercise.exercise_time'.tr()),
                        _buildTimeField(),

                        SizedBox(height: 20.h),

                        // Number of Sets
                        AppFieldLabel(text: 'add_exercise.number_of_sets'.tr()),
                        AppTextField(
                          controller: _setsController,
                          hintText: 'add_exercise.number_of_sets_hint'.tr(),
                          keyboardType: TextInputType.number,
                        ),

                        SizedBox(height: 20.h),

                        // Rest Duration
                        AppFieldLabel(text: 'add_exercise.rest_duration'.tr()),
                        AppTextField(
                          controller: _restController,
                          hintText: 'add_exercise.rest_duration_hint'.tr(),
                          keyboardType: TextInputType.number,
                          suffixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            child: Text(
                              'ثانية',
                              style: TextStyleManager.style11Medium.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Number of Reps
                        AppFieldLabel(text: 'add_exercise.number_of_reps'.tr()),
                        AppTextField(
                          controller: _repsController,
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
                    text: widget.workoutItemId != null
                        ? 'visit_details.save'.tr()
                        : 'add_exercise.add_button'.tr(),
                    color: AppColors.primary,
                    onPressed: _onSave,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    final formatTime = DateFormat('hh:mm a', context.locale.languageCode);
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);

    return AppTextField(
      hintText: formatTime.format(dt),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      readOnly: true,
      suffixIcon: Icon(
        Icons.access_time_rounded,
        color: AppColors.primary,
        size: 20.sp,
      ),
    );
  }

  Future<void> _onSave() async {
    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار اسم التمرين أولاً'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final sets = int.tryParse(_setsController.text) ?? 3;
    final reps = int.tryParse(_repsController.text) ?? 12;
    final rest = int.tryParse(_restController.text) ?? 60;

    final now = DateTime.now();
    final timeStr = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute).toUtc().toIso8601String();

    setState(() => _isLoading = true);
    final cubit = context.read<VisitDetailsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final bool success;
    final String message;

    if (widget.workoutItemId != null) {
      // Edit mode (PATCH)
      final result = await cubit.updateWorkout(
        assessmentId: widget.assessmentId,
        dayNumber: widget.dayNumber,
        workoutItemId: widget.workoutItemId!,
        exerciseId: _selectedExercise!.id,
        sets: sets,
        reps: reps,
        restDuration: rest,
        time: timeStr,
      );
      success = result.$1;
      message = result.$2;
    } else {
      // Add mode (POST)
      final result = await cubit.addWorkout(
        assessmentId: widget.assessmentId,
        dayNumber: widget.dayNumber,
        exerciseId: _selectedExercise!.id,
        sets: sets,
        reps: reps,
        restDuration: rest,
        time: timeStr,
      );
      success = result.$1;
      message = result.$2;
    }

    setState(() => _isLoading = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.primary : AppColors.error,
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }
}
