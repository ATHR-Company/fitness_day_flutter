import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class ExerciseDetailsDialog extends StatefulWidget {
  const ExerciseDetailsDialog({super.key});

  @override
  State<ExerciseDetailsDialog> createState() => _ExerciseDetailsDialogState();
}

class _ExerciseDetailsDialogState extends State<ExerciseDetailsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    
    // Initialize dummy video player for demonstration
    // Since we don't have a real URL, we'll just handle it gracefully if it fails
    // or use a placeholder in the UI if not initialized.
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
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
                        'exercise_details_dialog.title'.tr(),
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

              // Video Player Placeholder
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(16.r),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800'),
                        fit: BoxFit.cover,
                      )
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow, color: AppColors.white, size: 32.sp),
                      ),
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
                    _buildStepsList(),
                    _buildRepsList(),
                    _buildWarningsList(),
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
                        context.push(UserAppRoutes.workoutVideo);
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
          ),
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      children: [
        _buildListItem(Icons.check_circle_outline, 'exercise_details_dialog.step_1'.tr(), AppColors.primary),
        _buildListItem(Icons.check_circle_outline, 'exercise_details_dialog.step_2'.tr(), AppColors.primary),
        _buildListItem(Icons.check_circle_outline, 'exercise_details_dialog.step_3'.tr(), AppColors.primary),
        _buildListItem(Icons.check_circle_outline, 'exercise_details_dialog.step_4'.tr(), AppColors.primary),
        _buildListItem(Icons.check_circle_outline, 'exercise_details_dialog.step_5'.tr(), AppColors.primary),
        _buildListItem(Icons.check_circle_outline, 'exercise_details_dialog.step_6'.tr(), AppColors.primary),
      ],
    );
  }

  Widget _buildRepsList() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      children: [
        _buildListItem(Icons.access_time, 'exercise_details_dialog.rep_1'.tr(), AppColors.primary),
        _buildListItem(Icons.access_time, 'exercise_details_dialog.rep_2'.tr(), AppColors.primary),
        _buildListItem(Icons.access_time, 'exercise_details_dialog.rep_3'.tr(), AppColors.primary),
        _buildListItem(Icons.access_time, 'exercise_details_dialog.rep_3'.tr(), AppColors.primary),
      ],
    );
  }

  Widget _buildWarningsList() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      children: [
        _buildListItem(Icons.warning_amber_rounded, 'exercise_details_dialog.warn_1'.tr(), AppColors.error),
        _buildListItem(Icons.warning_amber_rounded, 'exercise_details_dialog.warn_2'.tr(), AppColors.error),
        _buildListItem(Icons.warning_amber_rounded, 'exercise_details_dialog.warn_3'.tr(), AppColors.error),
        _buildListItem(Icons.warning_amber_rounded, 'exercise_details_dialog.warn_4'.tr(), AppColors.error),
      ],
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
              style: TextStyleManager.style9Medium,
            ),
          ),
        ],
      ),
    );
  }
}
