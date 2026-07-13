import 'dart:async';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:go_router/go_router.dart';

class WorkoutRestScreen extends StatefulWidget {
  final int restDuration;

  const WorkoutRestScreen({
    super.key,
    required this.restDuration,
  });

  @override
  State<WorkoutRestScreen> createState() => _WorkoutRestScreenState();
}

class _WorkoutRestScreenState extends State<WorkoutRestScreen> {
  late int _countdown;
  late final int _maxRestDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _countdown = widget.restDuration;
    _maxRestDuration = widget.restDuration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _onNextStage();
      }
    });
  }

  void _onNextStage() {
    context.pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.headerBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              'exercise_details_dialog.title'.tr(),
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: AppColors.black, size: 24.sp),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Stack(
        children: [
          // Background top element
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 60.h,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.headerBackground,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 16.h),
                // Tabs (inactive for rest, but showing current context)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: IgnorePointer(
                    child: AppSegmentedControl(
                      type: AppSegmentedControlType.unified,
                      items: [
                        LocaleKeys.workout_warmup.tr(),
                        LocaleKeys.workout_exercises.tr(),
                        LocaleKeys.workout_cooldown.tr(),
                      ],
                      selectedIndex: 1, // Still on exercises, but resting
                      onItemSelected: (index) {},
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Timer Huge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '00:${_countdown.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        's',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  LocaleKeys.workout_rest_time.tr(),
                  style: TextStyleManager.style14Medium.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 48.h),

                // Hourglass Icon
                Center(
                  child: SizedBox(
                    width: 200.r,
                    height: 200.r,
                    child: Center(
                      child: AppImage(
                        SvgIcons.breakIcon,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Skip Rest Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: ElevatedButton(
                      onPressed: () {
                        _timer?.cancel();
                        _onNextStage();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                      ),
                      child: Text(
                        LocaleKeys.workout_skip_rest.tr(),
                        style: TextStyleManager.style14Bold.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ),

                // Bottom Progress
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('0', style: TextStyleManager.style12Regular),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4.h,
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: AppColors.divider,
                                thumbColor: AppColors.primary,
                                overlayColor: AppColors.primary.withValues(alpha: 0.2),
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                              ),
                              child: Slider(
                                value: _maxRestDuration == 0 ? 0.0 : (_maxRestDuration - _countdown) / _maxRestDuration,
                                onChanged: (val) {},
                              ),
                            ),
                          ),
                          Text('$_maxRestDuration s', style: TextStyleManager.style12Regular),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.fast_rewind, color: AppColors.divider),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh, color: AppColors.divider),
                            onPressed: () {
                              setState(() {
                                _countdown = _maxRestDuration;
                              });
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_timer != null && _timer!.isActive) {
                                _timer!.cancel();
                                setState(() {});
                              } else {
                                _startTimer();
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              padding: EdgeInsets.all(12.r),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                (_timer != null && _timer!.isActive) ? Icons.pause : Icons.play_arrow,
                                color: AppColors.white,
                                size: 28.sp,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.play_arrow_outlined, color: AppColors.divider),
                            onPressed: () {
                              if (_timer == null || !_timer!.isActive) {
                                _startTimer();
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.fast_forward, color: AppColors.divider),
                            onPressed: () {
                              _timer?.cancel();
                              _onNextStage();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
