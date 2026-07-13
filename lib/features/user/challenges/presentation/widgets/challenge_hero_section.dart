import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

/// Hero image with a floating "achieved X%" badge, shown at the top of the
/// active challenge screen.
class ChallengeHeroSection extends StatelessWidget {
  final String? imageUrl;
  final int achievedPercent;

  static const _fallback =
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400';

  const ChallengeHeroSection({
    super.key,
    this.imageUrl,
    this.achievedPercent = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        AppImage(
          imageUrl ?? _fallback,
          height: 200.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: -15.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
            decoration: BoxDecoration(
              gradient: AppColors.timeRemainingGradient,
              border: Border.all(color: AppColors.greenMint, width: 1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'challenges.achieved_percent'.tr(args: ['$achievedPercent']),
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.greenDarkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
