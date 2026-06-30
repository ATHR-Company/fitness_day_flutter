import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/workout/presentation/widgets/workout_achievement_dialog.dart';

class WorkoutMapScreen extends StatefulWidget {
  const WorkoutMapScreen({super.key});

  @override
  State<WorkoutMapScreen> createState() => _WorkoutMapScreenState();
}

class _WorkoutMapScreenState extends State<WorkoutMapScreen> {
  int _secondsElapsed = 0;
  Timer? _timer;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _finishWorkout() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const WorkoutAchievementDialog(),
    ).then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
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
      body: Stack(
        children: [
          // Map Background Placeholder
          Positioned.fill(
            child: Container(
              color: AppColors.divider,
              child: Image.network(
                'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800',
                fit: BoxFit.cover,
                color: Colors.white.withValues(alpha: 0.8),
                colorBlendMode: BlendMode.screen,
              ),
            ),
          ),
          
          // Header Stats (Steps)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '500',
                              style: TextStyleManager.heading2.copyWith(color: AppColors.black),
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.directions_walk, color: AppColors.primary, size: 24.sp),
                          ],
                        ),
                        Text(
                          'خطوة',
                          style: TextStyleManager.style12Regular.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 48.w), // Balance
                ],
              ),
            ),
          ),

          // Bottom Sheet Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  
                  // Progress Bar
                  Row(
                    children: [
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
                            value: 0.5,
                            onChanged: (val) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0', style: TextStyleManager.style12Regular),
                      Text('30 دقيقة', style: TextStyleManager.style12Regular),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('المسافة', '2.0', 'كم'),
                      _buildStatColumn('الوقت', '00:30', 'دقيقة'),
                      _buildStatColumn('السعرات', '50', 'سعر'),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _finishWorkout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            'انهاء',
                            style: TextStyleManager.style14Bold.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _togglePlay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            elevation: 0,
                          ),
                          child: Text(
                            _isPlaying ? 'استراحة' : 'متابعة',
                            style: TextStyleManager.style14Bold.copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyleManager.style12Regular.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyleManager.heading2.copyWith(color: AppColors.black),
        ),
        Text(
          unit,
          style: TextStyleManager.style12Regular.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
