import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/features/user/workout/presentation/widgets/workout_success_dialog.dart';
import 'package:fitness_day/features/user/workout/presentation/widgets/workout_pause_dialog.dart';
import 'package:fitness_day/features/user/workout/presentation/manager/workout_details_cubit.dart';
import 'package:fitness_day/features/user/workout/presentation/manager/workout_details_state.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_details_model.dart';

enum ExercisePhase { warmup, exercise, cooldown }

class WorkoutVideoScreen extends StatefulWidget {
  final String workoutItemId;
  final String assessmentId;
  final int dayNumber;

  const WorkoutVideoScreen({
    super.key,
    required this.workoutItemId,
    required this.assessmentId,
    required this.dayNumber,
  });

  @override
  State<WorkoutVideoScreen> createState() => _WorkoutVideoScreenState();
}

class _WorkoutVideoScreenState extends State<WorkoutVideoScreen> {
  ExercisePhase _currentPhase = ExercisePhase.warmup;
  int _selectedTab = 0;
  int _currentSet = 1;
  int _totalSets = 3;
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _isMuted = false;
  WorkoutDetailsModel? _workout;
  String _currentVideoUrl = '';

  @override
  void initState() {
    super.initState();
  }

  void _initializePhaseVideo(String videoUrl) {
    if (videoUrl == _currentVideoUrl && _videoController != null) return;
    _currentVideoUrl = videoUrl;

    _videoController?.dispose();
    _isPlaying = false;

    if (videoUrl.isEmpty) {
      // Fallback dummy controller to avoid crashes if URL is missing
      _videoController = VideoPlayerController.asset('assets/video/workout.mp4')
        ..initialize().then((_) {
          if (mounted) {
            _videoController!.setVolume(_isMuted ? 0.0 : 1.0);
            _videoController!.setLooping(true);
            setState(() {});
          }
        });
      return;
    }

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          _videoController!.setVolume(_isMuted ? 0.0 : 1.0);
          _videoController!.setLooping(true);
          setState(() {});
        }
      });
  }

  String _getVideoUrlForPhase(ExercisePhase phase) {
    if (_workout == null) return '';
    switch (phase) {
      case ExercisePhase.warmup:
        return _workout!.phases.warmup?.videoUrl ?? '';
      case ExercisePhase.exercise:
        return _workout!.phases.exercise?.videoUrl ?? '';
      case ExercisePhase.cooldown:
        return _workout!.phases.coolDown?.videoUrl ?? '';
    }
  }

  void _onNextStage() {
    if (_currentPhase == ExercisePhase.warmup) {
      setState(() {
        _currentPhase = ExercisePhase.exercise;
        _selectedTab = 1;
      });
      _initializePhaseVideo(_getVideoUrlForPhase(ExercisePhase.exercise));
    } else if (_currentPhase == ExercisePhase.cooldown) {
      _videoController?.pause();
      setState(() => _isPlaying = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const WorkoutSuccessDialog(),
      ).then((_) {
        if (mounted) {
          // Go back to the workout plan page
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    _videoController?.pause();
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
      _videoController?.play();
      return false;
    }
    return true;
  }

  void _togglePlayPause() {
    if (_videoController == null || !_videoController!.value.isInitialized)
      return;
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoController!.play();
      } else {
        _videoController!.pause();
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
              _videoController?.play();
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
      child: BlocProvider(
        create: (context) {
            final assId = widget.assessmentId.isNotEmpty
                ? widget.assessmentId
                : (getIt<AppCache>().getAssessmentId() ?? '');
            return getIt<WorkoutDetailsCubit>()
              ..getWorkoutDetails(
                  assId, widget.dayNumber, widget.workoutItemId);
          },
        child: BlocConsumer<WorkoutDetailsCubit, WorkoutDetailsState>(
          listener: (context, state) {
            if (state is WorkoutDetailsSuccess) {
              setState(() {
                _workout = state.workout;
                _totalSets = state.workout.totalSets;
                if (state.workout.completedSets >= _totalSets) {
                  _currentSet = 1;
                } else {
                  _currentSet = state.workout.completedSets + 1;
                }
              });
              _initializePhaseVideo(_getVideoUrlForPhase(_currentPhase));
            } else if (state is WorkoutSetCompletionSuccess) {
              if (_currentSet >= _totalSets) {
                // Done with all sets! Move to cooldown
                _videoController?.pause();
                setState(() {
                  _currentPhase = ExercisePhase.cooldown;
                  _selectedTab = 2;
                });
                _initializePhaseVideo(_getVideoUrlForPhase(ExercisePhase.cooldown));
              } else {
                // Move to next set after resting
                _videoController?.pause();
                final nextSet = _currentSet + 1;
                setState(() {
                  _isPlaying = false;
                  _currentSet = nextSet;
                });

                context.push(UserAppRoutes.workoutRest, extra: _workout?.restDuration ?? 30).then((_) {
                  if (mounted) {
                    _videoController?.seekTo(Duration.zero);
                    setState(() {});
                  }
                });
              }
            } else if (state is WorkoutSetCompletionFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final isAr = context.locale.languageCode == 'ar';

            String phaseSubtitle = '';
            if (_workout != null) {
              switch (_currentPhase) {
                case ExercisePhase.warmup:
                  phaseSubtitle = isAr ? 'الإحماء' : 'Warmup';
                case ExercisePhase.exercise:
                  phaseSubtitle = '$_currentSet / $_totalSets';
                case ExercisePhase.cooldown:
                  phaseSubtitle = isAr ? 'التهدئة' : 'Cooldown';
              }
            }

            return Scaffold(
              backgroundColor: AppColors.white,
              appBar: AppBar(
                backgroundColor: AppColors.headerBackground,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.black,
                    size: 20.sp,
                  ),
                  onPressed: () async {
                    if (await _onBackPressed()) {
                      if (mounted) Navigator.of(context).pop();
                    }
                  },
                ),
                title: Column(
                  children: [
                    Text(
                      _workout?.name ?? 'exercise_details_dialog.title'.tr(),
                      style: TextStyleManager.heading2.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      phaseSubtitle,
                      style: TextStyleManager.style14Medium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: AppColors.black,
                      size: 24.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                        _videoController?.setVolume(_isMuted ? 0.0 : 1.0);
                      });
                    },
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
              body: state is WorkoutDetailsLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : state is WorkoutDetailsFailure
                  ? Center(
                      child: Text(
                        state.message,
                        style: TextStyleManager.style14Medium.copyWith(
                          color: AppColors.red,
                        ),
                      ),
                    )
                  : _workout == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : Stack(
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

                              // Reps Display instead of timer countdown
                              _currentPhase == ExercisePhase.exercise
                                  ? Text(
                                      isAr
                                          ? '${_workout!.reps} تكرار'
                                          : '${_workout!.reps} Reps',
                                      style: TextStyle(
                                        fontSize: 40.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Text(
                                      _currentPhase == ExercisePhase.warmup
                                          ? (isAr ? 'الإحماء' : 'Warmup')
                                          : (isAr ? 'التهدئة' : 'Cooldown'),
                                      style: TextStyle(
                                        fontSize: 40.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                              SizedBox(height: 24.h),

                              // Video Area
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.w),
                                child: AspectRatio(
                                  aspectRatio: 2.5 / 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.divider,
                                      borderRadius: BorderRadius.circular(24.r),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (_videoController != null &&
                                            _videoController!
                                                .value
                                                .isInitialized)
                                          Positioned.fill(
                                            child: VideoPlayer(
                                              _videoController!,
                                            ),
                                          )
                                        else
                                          const Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.primary,
                                            ),
                                          ),

                                        // Play/Pause Overlay
                                        GestureDetector(
                                          onTap: _togglePlayPause,
                                          child: Container(
                                            padding: EdgeInsets.all(16.r),
                                            decoration: BoxDecoration(
                                              color: AppColors.white.withValues(
                                                alpha: _isPlaying ? 0.0 : 0.6,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: _isPlaying
                                                  ? Colors.transparent
                                                  : AppColors.white,
                                              size: 40.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),

                              // Bottom Completed Action Button
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 8.h,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48.h,
                                  child: state is WorkoutSetCompletionLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () {
                                            if (_currentPhase ==
                                                ExercisePhase.warmup) {
                                              _onNextStage();
                                            } else if (_currentPhase ==
                                                ExercisePhase.cooldown) {
                                              _onNextStage();
                                            } else {
                                              // Complete Set API Call
                                              context
                                                  .read<WorkoutDetailsCubit>()
                                                  .completeWorkoutSet(
                                                    assessmentId: widget.assessmentId.isNotEmpty
                                                        ? widget.assessmentId
                                                        : (getIt<AppCache>().getAssessmentId() ?? ''),
                                                    dayNumber: widget.dayNumber,
                                                    workoutItemId:
                                                        widget.workoutItemId,
                                                    setNumber: _currentSet,
                                                  );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24.r),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            _currentPhase ==
                                                    ExercisePhase.warmup
                                                ? (isAr
                                                      ? 'تم وابدأ التمرين'
                                                      : 'Done & Start Exercise')
                                                : _currentPhase ==
                                                      ExercisePhase.cooldown
                                                ? (isAr
                                                      ? 'إنهاء التمرين'
                                                      : 'Finish Workout')
                                                : (isAr
                                                      ? 'إكمال المجموعة $_currentSet'
                                                      : 'Complete Set $_currentSet'),
                                            style: TextStyleManager.style14Bold
                                                .copyWith(
                                                  color: AppColors.white,
                                                ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
