import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/features/user/workout/presentation/widgets/workout_success_dialog.dart';
import 'package:fitness_day/features/user/workout/presentation/widgets/workout_pause_dialog.dart';

enum ExercisePhase { warmup, exercise, cooldown }

class WorkoutVideoScreen extends StatefulWidget {
  const WorkoutVideoScreen({super.key});

  @override
  State<WorkoutVideoScreen> createState() => _WorkoutVideoScreenState();
}

class _WorkoutVideoScreenState extends State<WorkoutVideoScreen> {
  ExercisePhase _currentPhase = ExercisePhase.warmup;
  int _selectedTab = 0;
  int _currentSet = 1;
  final int _totalSets = 3;
  late VideoPlayerController _videoController;
  bool _isPlaying = false;
  int _maxCountdown = 8;
  int _countdown = 8;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Dummy video player initialization
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
    )..initialize().then((_) {
        _videoController.setVolume(0.0);
        _videoController.setLooping(true);
        setState(() {});
      });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0 && _isPlaying) {
        setState(() {
          _countdown--;
        });
      } else if (_countdown == 0) {
        timer.cancel();
        _onNextStage();
      }
    });
  }

  void _onNextStage() {
    if (_currentPhase == ExercisePhase.warmup) {
      setState(() {
        _currentPhase = ExercisePhase.exercise;
        _selectedTab = 1;
        _maxCountdown = 15;
        _countdown = 15;
      });
      if (_isPlaying) _startTimer();
    } else if (_currentPhase == ExercisePhase.exercise) {
      if (_currentSet < _totalSets) {
        _videoController.pause();
        _timer?.cancel();
        context.push(UserAppRoutes.workoutRest).then((_) {
          if (!mounted) return;
          setState(() {
            _currentSet++;
            _maxCountdown = 15;
            _countdown = 15;
          });
          if (_isPlaying) {
            _startTimer();
            _videoController.play();
          }
        });
      } else {
        setState(() {
          _currentPhase = ExercisePhase.cooldown;
          _selectedTab = 2;
          _maxCountdown = 10;
          _countdown = 10;
        });
        if (_isPlaying) _startTimer();
      }
    } else if (_currentPhase == ExercisePhase.cooldown) {
      _timer?.cancel();
      _videoController.pause();
      setState(() => _isPlaying = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const WorkoutSuccessDialog(),
      ).then((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    _videoController.pause();
    _timer?.cancel();
    setState(() => _isPlaying = false);
    
    bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => WorkoutPauseDialog(
        onEnd: () {
          Navigator.of(context).pop(true);
        },
        onContinue: () {
          Navigator.of(context).pop(false);
        },
      ),
    );
    
    if (shouldPop == false) {
      setState(() => _isPlaying = true);
      _videoController.play();
      _startTimer();
      return false;
    }
    return true;
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoController.play();
        if (_timer == null || !_timer!.isActive) {
          _startTimer();
        }
      } else {
        _videoController.pause();
        _timer?.cancel();
        showDialog(
          context: context,
          builder: (context) => WorkoutPauseDialog(
            onEnd: () {
              Navigator.of(context).pop();
              if (mounted) Navigator.of(context).pop();
            },
            onContinue: () {
              Navigator.of(context).pop();
              setState(() => _isPlaying = true);
              _videoController.play();
              _startTimer();
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.headerBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
          onPressed: () async {
            if (await _onBackPressed()) {
              if (mounted) Navigator.of(context).pop();
            }
          },
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
            Text(
              '${_currentPhase == ExercisePhase.warmup ? 0 : _currentSet} / $_totalSets',
              style: TextStyleManager.style14Medium.copyWith(color: AppColors.primary),
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
                // Tabs
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
                      selectedIndex: _selectedTab,
                      onItemSelected: (index) {},
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Timers
                Text(
                  '00:${_countdown.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                // Text(
                //   'متبقي 00:12',
                //   style: TextStyleManager.style12Regular.copyWith(color: AppColors.textSecondary),
                // ),
                // SizedBox(height: 24.h),

                // Video Area
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(24.r),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: AppColors.white,
                              size: 40.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                // Bottom button overlay (if needed)
                if (!_isPlaying)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _togglePlayPause,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'ابدا الآن', // Start Now
                          style: TextStyleManager.style14Bold.copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                  ),

                // Bottom Controls
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    children: [
                      // Progress Bar
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
                                value: _maxCountdown == 0 ? 0 : (_maxCountdown - _countdown) / _maxCountdown,
                                onChanged: (val) {},
                              ),
                            ),
                          ),
                          Text('30 s', style: TextStyleManager.style12Regular),
                        ],
                      ),
                      // Media Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.fast_rewind, color: AppColors.divider),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh, color: AppColors.divider),
                            onPressed: () {},
                          ),
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              padding: EdgeInsets.all(12.r),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: AppColors.white,
                                size: 28.sp,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.play_arrow_outlined, color: AppColors.divider),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.fast_forward, color: AppColors.divider),
                            onPressed: () {},
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
    ));
  }
}
