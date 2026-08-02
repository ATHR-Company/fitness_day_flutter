import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:fitness_day/core/routes/shared/shared_routes.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/features/shared/onboarding/data/models/onboarding_content.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import 'package:fitness_day/core/widgets/app_image.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentIndex = 0;

  late final List<OnboardingContent> _contents;

  @override
  void initState() {
    super.initState();
    _contents = [
      OnboardingContent(
        imagePath: AppImages.onboarding1,
        title: LocaleKeys.onboarding_title_1.tr(),
        subtitle: LocaleKeys.onboarding_subtitle_1.tr(),
      ),
      OnboardingContent(
        imagePath: AppImages.onboarding2,
        title: LocaleKeys.onboarding_title_2.tr(),
        subtitle: LocaleKeys.onboarding_subtitle_2.tr(),
      ),
      OnboardingContent(
        imagePath: AppImages.onboarding3,
        title: LocaleKeys.onboarding_title_3.tr(),
        subtitle: LocaleKeys.onboarding_subtitle_3.tr(),
      ),
    ];
  }

  void _nextPage() {
    if (_currentIndex < _contents.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  Future<void> _finishOnboarding() async {
    await di.getIt<AppCache>().saveHasSeenOnboarding(true);
    if (mounted) context.go(SharedRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: InkWell(
                    onTap: _finishOnboarding,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LocaleKeys.onboarding_skip
                                .tr()
                                .replaceAll('»', '')
                                .trim(),
                            style: TextStyleManager.style14Medium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Directionality.of(context) == ui.TextDirection.rtl
                                ? Icons.keyboard_double_arrow_left_rounded
                                : Icons.keyboard_double_arrow_right_rounded,
                            size: 16.w,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Animated Content
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    final isRTL =
                        Directionality.of(context) == ui.TextDirection.rtl;

                    if (details.primaryVelocity! < 0) {
                      // Swiping Left (Right to Left)
                      isRTL ? _prevPage() : _nextPage();
                    } else if (details.primaryVelocity! > 0) {
                      // Swiping Right (Left to Right)
                      isRTL ? _nextPage() : _prevPage();
                    }
                  },
                  child: Container(
                    color: Colors
                        .transparent, // Ensure gesture detector captures touches
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image & Indicators — fixed height
                        SizedBox(
                          height: 350.h,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: AppImage(
                                  _contents[_currentIndex].imagePath,
                                  key: ValueKey<int>(_currentIndex),
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: 350.h,
                                ),
                              ),
                              Positioned(
                                bottom: 24.h,
                                child: _buildDotsIndicator(),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Title & Subtitle — flexible, shrinks only if no space
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                  child: _AdaptiveOnboardingText(
                                    key: ValueKey<int>(_currentIndex),
                                    title: _contents[_currentIndex].title,
                                    subtitle: _contents[_currentIndex].subtitle,
                                    titleStyle: TextStyleManager.heading1,
                                    subtitleStyle: TextStyleManager.style13Medium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxWidth: constraints.maxWidth,
                                    maxHeight: constraints.maxHeight,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Progress Button
              Padding(
                padding: EdgeInsets.only(bottom: 40.h, top: 20.h),
                child: _buildProgressButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _contents.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index ? AppColors.primary : AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressButton() {
    final bool isLastPage = _currentIndex == _contents.length - 1;
    final double progress = (_currentIndex + 1) / _contents.length;

    return GestureDetector(
      onTap: _nextPage,
      child: SizedBox(
        width: 80.w,
        height: 80.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular Progress Background
            Transform.rotate(
              angle: Directionality.of(context) == ui.TextDirection.rtl ? (math.pi / 2) : (-math.pi / 2),
              child: SizedBox(
                width: 80.w,
                height: 80.w,
                child: CircularProgressIndicator(
                  // Remove hardcoded LTR so it naturally fills clockwise in LTR and counter-clockwise in RTL
                  value: 1.0,
                  strokeWidth: 4.w,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            // Actual Circular Progress
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: Directionality.of(context) == ui.TextDirection.rtl ? (math.pi / 2) : (-math.pi / 2),
                  child: SizedBox(
                    width: 80.w,
                    height: 80.w,
                    child: Directionality(
                      textDirection: Directionality.of(context) == ui.TextDirection.rtl 
                          ? ui.TextDirection.ltr 
                          : ui.TextDirection.rtl,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 4.w,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Inner Button
            Container(
              width: 60.w,
              height: 60.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Icon(
                  isLastPage
                      ? Icons.check
                      : (Directionality.of(context) == ui.TextDirection.rtl
                            ? Icons.keyboard_double_arrow_left_rounded
                            : Icons.keyboard_double_arrow_right_rounded),
                  key: ValueKey<bool>(isLastPage),
                  color: AppColors.white,
                  size: 32.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdaptiveOnboardingText extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final double maxWidth;
  final double maxHeight;

  const _AdaptiveOnboardingText({
    super.key,
    required this.title,
    required this.subtitle,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    double scale = 1.0;
    const double minScale = 0.5;
    const double step = 0.05;

    while (scale > minScale) {
      final scaledTitleStyle = titleStyle.copyWith(
        fontSize: (titleStyle.fontSize ?? 19.sp) * scale,
      );
      final scaledSubtitleStyle = subtitleStyle.copyWith(
        fontSize: (subtitleStyle.fontSize ?? 13.sp) * scale,
      );

      // Measure title height
      final titlePainter = TextPainter(
        text: TextSpan(text: title, style: scaledTitleStyle),
        textDirection: Directionality.of(context),
      )..layout(maxWidth: maxWidth);

      // Measure subtitle height
      final subtitlePainter = TextPainter(
        text: TextSpan(text: subtitle, style: scaledSubtitleStyle),
        textDirection: Directionality.of(context),
      )..layout(maxWidth: maxWidth);

      final totalHeight = titlePainter.height + 10.h + subtitlePainter.height;

      if (totalHeight <= maxHeight) {
        break;
      }
      scale -= step;
    }

    if (scale < minScale) {
      scale = minScale;
    }

    final finalTitleStyle = titleStyle.copyWith(
      fontSize: (titleStyle.fontSize ?? 19.sp) * scale,
    );
    final finalSubtitleStyle = subtitleStyle.copyWith(
      fontSize: (subtitleStyle.fontSize ?? 13.sp) * scale,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: finalTitleStyle,
        ),
        SizedBox(height: 10.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: finalSubtitleStyle,
        ),
      ],
    );
  }
}
