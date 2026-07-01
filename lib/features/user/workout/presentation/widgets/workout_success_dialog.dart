import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal() {
    player.setPlayerMode(PlayerMode.lowLatency);
  }

  final AudioPlayer player = AudioPlayer();

  Future<void> playClaps() async {
    try {
      if (player.state == PlayerState.playing) {
        await player.stop();
      }
      await player.play(AssetSource('audio/claps.mp3'));
    } catch (e) {
      debugPrint("Could not play sound: $e");
    }
  }
}

class WorkoutSuccessDialog extends StatefulWidget {
  const WorkoutSuccessDialog({super.key});

  @override
  State<WorkoutSuccessDialog> createState() => _WorkoutSuccessDialogState();
}

class _WorkoutSuccessDialogState extends State<WorkoutSuccessDialog> {
  @override
  void initState() {
    super.initState();
    SoundManager().playClaps();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFB5FFD9), // Light green
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, color: const Color(0xFF00A900), size: 32.sp),
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Icon
                SvgPicture.asset(
                  'assets/svg/workout_popup.svg',
                  width: 120.r,
                  height: 120.r,
                ),
                SizedBox(height: 32.h),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '👏',
                      style: TextStyle(fontSize: 24.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'أحسنت',
                      textAlign: TextAlign.center,
                      style: TextStyleManager.heading2.copyWith(
                        color: const Color(0xFF00A900),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Description
                Text(
                  'لقد أكملت جميع الجولات بنجاح. استمر على هذا الأداء\nللحفاظ على تقدمك وتحسين لياقتك.',
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style14Medium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
          
          // Celebration Animation
          IgnorePointer(
            child: Lottie.network(
              'https://assets3.lottiefiles.com/packages/lf20_u4yrau.json', // Common confetti url
              repeat: false,
              width: 300.r,
              height: 300.r,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
