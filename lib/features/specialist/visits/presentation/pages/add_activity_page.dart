import 'dart:ui' as ui;
import 'package:collection/collection.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
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
import 'package:fitness_day/core/utils/plan_day_time.dart';
import 'package:fitness_day/features/specialist/visits/data/datasources/specialist_visits_remote_datasource.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_plan_lookups_model.dart';
import 'package:fitness_day/features/specialist/visits/presentation/manager/visit_details_cubit.dart';


class AddActivityPage extends StatefulWidget {
  final String assessmentId;
  final int dayNumber;
  final String weekStart; // Assessment week start — base date for the day

  /// The activity item being edited, or null in add mode. Carries the activity
  /// id, the goal and the stored time, so the screen opens populated without a
  /// round trip.
  final SpecialistActivityModel? activity;

  const AddActivityPage({
    super.key,
    required this.assessmentId,
    required this.dayNumber,
    required this.weekStart,
    this.activity,
  });

  bool get isEditMode => activity != null;

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _remoteDataSource = getIt<SpecialistVisitsRemoteDataSource>();

  List<SpecialistActivityLookupModel> _activities = [];
  SpecialistActivityLookupModel? _selectedActivity;

  /// An activity has no time of its own to pick — it runs across the whole day
  /// — but the API still takes one. In edit mode this holds whatever the item
  /// was already saved with, so changing the goal doesn't silently rewrite it.
  String? _existingTime;

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

    final SpecialistActivityModel? activity = widget.activity;
    if (activity != null) {
      // By id, not by name — matching on the display name fell through to
      // `_activities.first` whenever the backend reworded it, so editing
      // Hydration could quietly turn it into Walking.
      _selectedActivity =
          _activities.firstWhereOrNull((a) => a.id == activity.activityId);

      _goalController.text = activity.goal.toInt().toString();
      if (activity.time.isNotEmpty) _existingTime = activity.time;
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
      searchHintKey: 'add_activity.search_activity_name',
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
                      title: widget.isEditMode
                          ? 'add_activity.edit_title'.tr()
                          : 'add_activity.title'.tr(),
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
                                  ? Icons.chevron_right
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
                      text: widget.isEditMode
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
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _onSave() async {
    if (_selectedActivity == null) {
      showAppSnackBar(
        context,
        text: 'add_activity.select_name_first'.tr(),
        isError: true,
      );
      return;
    }

    final goal = int.tryParse(_goalController.text) ?? 0;

    // The screen no longer asks for a time, but `time` is still part of the
    // endpoint's contract. Editing resends what was already stored; a brand new
    // activity is stamped at the start of its own day, which is the closest
    // thing to "no particular time" the field can carry.
    final timeStr = _existingTime ??
        buildPlanItemTime(
          weekStart: widget.weekStart,
          dayNumber: widget.dayNumber,
          time: const TimeOfDay(hour: 0, minute: 0),
        );

    setState(() => _isLoading = true);
    final cubit = context.read<VisitDetailsCubit>();

    final bool success;
    final String message;

    if (widget.isEditMode) {
      // Edit mode (PATCH)
      final result = await cubit.updateActivity(
        assessmentId: widget.assessmentId,
        dayNumber: widget.dayNumber,
        activityItemId: widget.activity!.activityItemId,
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

    if (mounted) {
      showAppSnackBar(context, text: message, isSuccess: success, isError: !success);
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}
