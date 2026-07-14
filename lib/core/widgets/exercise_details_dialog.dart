import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/features/user/workout/presentation/manager/workout_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/features/user/workout/presentation/manager/workout_details_cubit.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_details_model.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

class ExerciseDetailsDialog extends StatefulWidget {
  final String? workoutItemId;
  final String? assessmentId;
  final int? dayNumber;

  const ExerciseDetailsDialog({
    super.key,
    this.workoutItemId,
    this.assessmentId,
    this.dayNumber,
  });

  @override
  State<ExerciseDetailsDialog> createState() => _ExerciseDetailsDialogState();
}

class _ExerciseDetailsDialogState extends State<ExerciseDetailsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final String _workoutItemId;
  late final int _dayNumber;

  @override
  void initState() {
    super.initState();
    _workoutItemId = widget.workoutItemId ?? '6a4cf59e38e6d8571647c112';
    _dayNumber = widget.dayNumber ?? 1;

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final assId = widget.assessmentId ?? (getIt<AppCache>().getAssessmentId() ?? '');
        return getIt<WorkoutDetailsCubit>()
          ..getWorkoutDetails(assId, _dayNumber, _workoutItemId);
      },
      child: BlocBuilder<WorkoutDetailsCubit, WorkoutDetailsState>(
        builder: (context, state) {
          return Dialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                child: state is WorkoutDetailsLoading
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    : state is WorkoutDetailsFailure
                        ? SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                state.message,
                                style: TextStyleManager.style14Medium.copyWith(color: AppColors.red),
                              ),
                            ),
                          )
                        : state is WorkoutDetailsSuccess
                            ? _buildDialogContent(context, state.workout)
                            : const SizedBox(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context, WorkoutDetailsModel workout) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 8.h),
          child: Row(
            children: [
              SizedBox(width: 32.w), // Balance spacer
              Expanded(
                child: Text(
                  workout.name,
                  textAlign: TextAlign.center,
                  style: TextStyleManager.heading3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, color: AppColors.primary, size: 28.sp),
              ),
            ],
          ),
        ),

        // Photo Area
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(16.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: workout.photo.isNotEmpty
                  ? AppImage(
                      workout.photo,
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Icon(Icons.image, color: AppColors.white, size: 48),
                    ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // TabBar using AppSegmentedControl
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: AppSegmentedControl(
            type: AppSegmentedControlType.unified,
            items: [
              'exercise_details_dialog.tab_steps'.tr(),
              'exercise_details_dialog.tab_repetitions'.tr(),
              'exercise_details_dialog.tab_precautions'.tr(),
            ],
            selectedIndex: _tabController.index,
            onItemSelected: (index) {
              _tabController.animateTo(index);
            },
          ),
        ),
        SizedBox(height: 16.h),

        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStepsList(workout.steps),
              _buildRepsList(context, workout),
              _buildWarningsList(workout.warnings),
            ],
          ),
        ),

        // Bottom Button
        Padding(
          padding: EdgeInsets.all(16.w),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                if (_tabController.index < 2) {
                  _tabController.animateTo(_tabController.index + 1);
                } else {
                  Navigator.of(context).pop();
                  context.push(
                    UserAppRoutes.workoutVideo,
                    extra: {
                      'workoutItemId': _workoutItemId,
                      'assessmentId': widget.assessmentId ?? '',
                      'dayNumber': _dayNumber,
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                elevation: 0,
              ),
              child: Text(
                _tabController.index < 2
                    ? 'exercise_details_dialog.btn_next'.tr()
                    : 'exercise_details_dialog.btn_start'.tr(),
                style: TextStyleManager.style14Bold.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepsList(List<String> steps) {
    if (steps.isEmpty) {
      return Center(
        child: Text(
          'exercise_details_dialog.no_steps'.tr(),
          style: TextStyleManager.style11Medium,
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return _buildListItem(
            Icons.check_circle_outline, steps[index], AppColors.primary);
      },
    );
  }

  Widget _buildRepsList(BuildContext context, WorkoutDetailsModel workout) {
    final isAr = context.locale.languageCode == 'ar';
    final setsLabel = isAr ? 'عدد المجموعات: ${workout.sets} مجموعات' : 'Sets: ${workout.sets}';
    final repsLabel = isAr ? 'عدد التكرار: ${workout.reps} تكرار' : 'Reps: ${workout.reps}';
    final restLabel = isAr
        ? 'مدة الاستراحة بين المجموعات: ${workout.restDuration} ثانية'
        : 'Rest: ${workout.restDuration} seconds';

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      children: [
        _buildListItem(Icons.fitness_center, setsLabel, AppColors.primary),
        _buildListItem(Icons.replay_rounded, repsLabel, AppColors.primary),
        _buildListItem(Icons.access_time, restLabel, AppColors.primary),
      ],
    );
  }

  Widget _buildWarningsList(List<String> warnings) {
    if (warnings.isEmpty) {
      return Center(
        child: Text(
          'exercise_details_dialog.no_warnings'.tr(),
          style: TextStyleManager.style11Medium,
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: warnings.length,
      itemBuilder: (context, index) {
        return _buildListItem(
            Icons.warning_amber_rounded, warnings[index], AppColors.error);
      },
    );
  }

  Widget _buildListItem(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyleManager.style11Medium,
            ),
          ),
        ],
      ),
    );
  }
}
