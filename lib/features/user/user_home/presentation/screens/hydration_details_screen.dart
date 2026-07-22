
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/activity_details_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/activity_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/hydration/manual_add_sheet.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/hydration/water_action_button.dart';

class HydrationDetailsScreen extends StatelessWidget {
  final String assessmentId;
  final int dayNumber;
  final String activityId;

  const HydrationDetailsScreen({
    super.key,
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActivityDetailsCubit>()
        ..getActivityDetails(assessmentId, dayNumber, activityId),
      child: const _HydrationDetailsContent(),
    );
  }
}

class _HydrationDetailsContent extends StatefulWidget {
  const _HydrationDetailsContent();

  @override
  State<_HydrationDetailsContent> createState() =>
      _HydrationDetailsContentState();
}

class _HydrationDetailsContentState extends State<_HydrationDetailsContent> {
  bool _isUpdating = false;

  void _showManualAddSheet(ActivityDetailsData data) {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: ManualAddSheet(
          onAdd: (amount) {
            context
                .read<ActivityDetailsCubit>()
                .increaseHydration(amount: amount);
          },
        ),
      ),
    );
  }

  Future<void> _onIncrease() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    await context.read<ActivityDetailsCubit>().increaseHydration(amount: 1.0);
    if (mounted) setState(() => _isUpdating = false);
  }

  Future<void> _onDecrease() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    await context.read<ActivityDetailsCubit>().decreaseHydration(amount: 0.25);
    if (mounted) setState(() => _isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityDetailsCubit, ActivityDetailsState>(
      builder: (context, state) {
        if (state is ActivityDetailsLoading) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ActivityDetailsFailure) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      color: AppColors.primary, size: 48.sp),
                  SizedBox(height: 12.h),
                  Text(state.message,
                      style: TextStyleManager.style11Medium,
                      textAlign: TextAlign.center),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('رجوع'),
                  ),
                ],
              ),
            ),
          );
        }

        // Success (or initial — shouldn't happen but guard anyway)
        final ActivityDetailsData? data =
            state is ActivityDetailsSuccess ? state.data : null;

        final double goal = data?.goal ?? 3.0;
        final double currentProgress = data?.currentProgress ?? 0.0;
        // Use progressPercentage from API (0–100), convert to 0.0–1.0
        final double rawPercent = (data?.progressPercentage ?? 0) / 100.0;
        final double percent = rawPercent.clamp(0.0, 1.0);
        final String unit = data?.unit ?? 'L';
        final String name = data?.name ?? 'hydration.title'.tr();

        return Scaffold(
          backgroundColor: AppColors.white,
          body: ScreenBackground(
            child: Stack(
              children: [
                // Decorative top-right
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: AppImage(
                    SvgIcons.decor,
                    fit: BoxFit.fill,
                    color: AppColors.hydrationDarkText.withValues(alpha: 0.05),
                  ),
                ),
                // Decorative bottom water BG
                PositionedDirectional(
                  bottom: 0,
                  end: 0,
                  start: 0,
                  child: AppImage(SvgIcons.WaterBG, fit: BoxFit.cover),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      // ── AppBar ──
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        child: Row(
                          children: [
                            // Arrow is the FIRST child:
                            // • RTL (Arabic)  → appears on the RIGHT  ✓
                            // • LTR (English) → appears on the LEFT   ✓
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Directionality.of(context) == ui.TextDirection.rtl
                                    ? Icons.arrow_back_ios
                                    : Icons.arrow_back_ios,
                                size: 20.sp,
                                color: AppColors.black,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              name,
                              style: TextStyleManager.heading3.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // ── Circular progress ──
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Loading overlay on the circle during update
                          IgnorePointer(
                            child: CircularPercentIndicator(
                              radius: 120.r,
                              lineWidth: 10.w,
                              percent: percent,
                              backgroundColor:
                                  AppColors.inactiveGray.withValues(alpha: 0.2),
                              progressColor: _isUpdating
                                  ? AppColors.hydrationAccent.withValues(alpha: 0.5)
                                  : AppColors.hydrationAccent,
                              animateFromLastPercent: true,
                              animation: true,
                              animationDuration: 400,
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppImage(SvgIcons.water_wave,
                                      width: 30.w, fit: BoxFit.cover),
                                  SizedBox(height: 25.h),
                                  // Current progress value
                                  Text(
                                    currentProgress
                                        .toStringAsFixed(2),
                                    style: TextStyleManager.heading1.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    '$unit ${goal.toStringAsFixed(0)}  /',
                                    style: TextStyleManager.style10Medium
                                        .copyWith(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Quick +1 button at bottom of circle
                          Positioned(
                            bottom: -20.h,
                            left: 0,
                            right: 0,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: WaterActionButton(
                                iconWidget: AppImage(SvgIcons.waterGlass,
                                    width: 40.w, height: 40.h),
                                label: '+1 $unit',
                                onTap: _isUpdating ? null : _onIncrease,
                                size: 80,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Action buttons row ──
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 40.h),
                              child: WaterActionButton(
                                iconWidget: AppImage(
                                  SvgIcons.WarterAdd,
                                  width: 30.w,
                                  height: 30.w,
                                  fit: BoxFit.contain,
                                ),
                                label: 'hydration.manual'.tr(),
                                onTap: data != null
                                    ? () => _showManualAddSheet(data)
                                    : null,
                                size: 80,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 40.h),
                              child: WaterActionButton(
                                iconWidget: Icon(
                                  Icons.remove,
                                  size: 30.sp,
                                  color: _isUpdating
                                      ? AppColors.hydrationAccent
                                          .withValues(alpha: 0.4)
                                      : AppColors.hydrationAccent,
                                ),
                                label: 'hydration.decrease'.tr(),
                                onTap: _isUpdating ? null : _onDecrease,
                                size: 80,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
