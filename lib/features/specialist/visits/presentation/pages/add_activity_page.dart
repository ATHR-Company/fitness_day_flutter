import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/selection_bottom_sheet.dart';
import 'package:fitness_day/core/widgets/app_text_field.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/specialist/visits/data/datasources/specialist_visits_remote_datasource.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_plan_lookups_model.dart';
import 'package:fitness_day/features/specialist/visits/presentation/manager/visit_details_cubit.dart';

import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';

class AddActivityPage extends StatefulWidget {
  final String assessmentId;
  final int dayNumber;
  final String? activityItemId; // If provided, it's Edit Mode

  const AddActivityPage({
    super.key,
    required this.assessmentId,
    required this.dayNumber,
    this.activityItemId,
  });

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _remoteDataSource = getIt<SpecialistVisitsRemoteDataSource>();

  List<SpecialistActivityLookupModel> _activities = [];
  SpecialistActivityLookupModel? _selectedActivity;

  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController _goalController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    try {
      final list = await _remoteDataSource.getActivities();
      _activities = list;
    } catch (_) {}
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    await _loadActivities();

    if (widget.activityItemId != null && _activities.isNotEmpty) {
      try {
        final activityDetailsResp = await _remoteDataSource.getActivityDetails(
          assessmentId: widget.assessmentId,
          dayNumber: widget.dayNumber,
          activityItemId: widget.activityItemId!,
        );
        final activityDetails = activityDetailsResp.data;

        // 1. Find and select activity lookup by name
        final matchedActivity = _activities.firstWhere(
          (a) => a.name.trim().toLowerCase() == activityDetails.name.trim().toLowerCase(),
          orElse: () => _activities.first,
        );
        _selectedActivity = matchedActivity;

        // 2. Set controllers
        _goalController.text = activityDetails.goal.toInt().toString();

        // 3. Parse time
        if (activityDetails.time != null && activityDetails.time!.isNotEmpty) {
          final parsed = DateTime.tryParse(activityDetails.time!);
          if (parsed != null) {
            _selectedTime = TimeOfDay.fromDateTime(parsed.toLocal());
          }
        }
      } catch (_) {}
    }

    setState(() => _isLoading = false);
  }

  void _showActivityNameSheet() {
    if (_activities.isEmpty) return;
    final items = _activities.map((a) => a.name).toList();
    showSelectionBottomSheet(
      context: context,
      title: 'add_activity.activity_name'.tr(),
      items: items,
      showSearch: true,
      initialSelectedIndex: _selectedActivity != null
          ? _activities.indexOf(_selectedActivity!)
          : 0,
      onConfirm: (index) {
        setState(() {
          _selectedActivity = _activities[index];
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
            child: TopCenteredConstrainedBox(
              horizontalPadding: 0,
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Back Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: AppBackHeader(
                      title: widget.activityItemId != null ? 'تعديل النشاط' : 'add_activity.title'.tr(),
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
                          // Activity Name
                          AppFieldLabel(text: 'add_activity.activity_name'.tr()),
                          AppTextField(
                            hintText:
                                _selectedActivity?.name ??
                                'add_activity.activity_name_hint'.tr(),
                            suffixIcon: Icon(
                              Directionality.of(context) == ui.TextDirection.rtl
                                  ? Icons.chevron_left
                                  : Icons.chevron_right,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                              size: 24.sp,
                            ),
                            onTap: _showActivityNameSheet,
                            valueColor: _selectedActivity != null
                                ? AppColors.black
                                : AppColors.textSecondary.withValues(alpha: 0.5),
                            readOnly: true,
                          ),

                          SizedBox(height: 20.h),

                          // Activity Time
                          AppFieldLabel(text: 'add_meal.meal_time'.tr()),
                          _buildTimeField(),

                          SizedBox(height: 20.h),

                          // Target Goal
                          AppFieldLabel(text: 'add_activity.target_goal'.tr()),
                          _buildTargetGoalField(),

                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),

                  // Add Button
                  Container(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                    child: CustomButton(
                      text: widget.activityItemId != null
                          ? 'visit_details.save'.tr()
                          : 'add_activity.add_button'.tr(),
                      color: AppColors.primary,
                      onPressed: _onSave,
                    ),
                  ),
                ],
              ),
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

  Widget _buildTargetGoalField() {
    return AppTextField(
      controller: _goalController,
      hintText: 'add_activity.target_goal_hint'.tr(),
      keyboardType: TextInputType.number,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      suffixIcon: _selectedActivity != null
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              child: Text(
                _selectedActivity!.unit,
                style: TextStyleManager.style10Medium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(4.w),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundTint,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'add_activity.step'.tr(),
                      style: TextStyleManager.style10Medium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _onSave() async {
    if (_selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار اسم النشاط أولاً'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final goal = int.tryParse(_goalController.text) ?? 0;

    final now = DateTime.now();
    final timeStr = DateTime(
      now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute,
    ).toUtc().toIso8601String();

    setState(() => _isLoading = true);
    final cubit = context.read<VisitDetailsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final bool success;
    final String message;

    if (widget.activityItemId != null) {
      // Edit mode (PATCH)
      final result = await cubit.updateActivity(
        assessmentId: widget.assessmentId,
        dayNumber: widget.dayNumber,
        activityItemId: widget.activityItemId!,
        activityId: _selectedActivity!.id,
        goal: goal,
        time: timeStr,
      );
      success = result.$1;
      message = result.$2;
    } else {
      // Add mode (POST)
      final result = await cubit.addActivity(
        assessmentId: widget.assessmentId,
        dayNumber: widget.dayNumber,
        activityId: _selectedActivity!.id,
        goal: goal,
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
