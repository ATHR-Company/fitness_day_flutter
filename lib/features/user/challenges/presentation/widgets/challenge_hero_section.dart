import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

/// Hero image with a floating "achieved X%" badge, shown at the top of the
/// active challenge screen.
class ChallengeHeroSection extends StatelessWidget {
  final String? imageUrl;

  /// The user's real percentage, the same figure the ring below draws.
  ///
  /// Required, not defaulted: it used to fall back to a literal `44` that no
  /// caller ever overrode, so every challenge claimed 44% however far along it
  /// actually was.
  final int achievedPercent;

  const ChallengeHeroSection({
    super.key,
    required this.achievedPercent,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl;
    final bool hasArtwork = url != null && url.isNotEmpty;

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 200.h,
          width: double.infinity,
          // `image` is null until an admin uploads artwork. This pointed at a
          // hardcoded Unsplash food photo, so an artwork-less challenge showed
          // a stock salad it had nothing to do with.
          child: hasArtwork
              ? AppImage(url,
                  height: 200.h, width: double.infinity, fit: BoxFit.cover)
              : ColoredBox(
                  color: AppColors.backgroundTint,
                  child: Center(
                    child: AppImage(
                      AppImages.challenge_cap,
                      height: 96.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
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
